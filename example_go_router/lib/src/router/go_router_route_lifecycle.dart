import 'dart:async';
import 'dart:collection';
// Platform detection - use conditional import for web compatibility
import 'dart:io' if (dart.library.html) 'dart:html' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Unified route lifecycle callback.
///
/// All lifecycle events pass only the [GoRouterState]. Using a single typedef
/// reduces API duplication while keeping old names (backwards compatible via
/// typedef aliases below).
typedef RouteLifecycleCallback = void Function(GoRouterState state);

/// Backwards compatible aliases (can be deprecated later if desired).
typedef PageShowCallback = RouteLifecycleCallback;
typedef PageHideCallback = RouteLifecycleCallback;
typedef PageForegroundCallback = RouteLifecycleCallback;
typedef PageBackgroundCallback = RouteLifecycleCallback;

/// Event type for the global route lifecycle stream.
enum RouteLifecycleEventType { show, hide, foreground, background }

/// Route lifecycle event data.
class RouteLifecycleEvent {
  RouteLifecycleEvent({required this.type, required this.state});
  final RouteLifecycleEventType type;
  final GoRouterState state;
}

/// A lightweight route lifecycle service that maps Page (pageKey) to
/// show/hide callbacks based on GoRouter's currentConfiguration diffs.
///
/// Route visibility definition:
///   A route is considered visible iff it lies on the current "visible path"
///   (root -> ... -> leaf) following the last RouteMatch and descending into
///   nested ShellRouteMatch.last until a non-shell leaf route is reached.
///
/// Notes:
///   * Works with StatefulShellRoute.indexedStack and normal GoRoutes.
///   * `go()` produces full hide events for previously visible routes, then
///     show for new visible routes (clearing stack semantics).
///   * Offstage branches (IndexedStack) are treated as hidden.
///   * Imperative routes (push/pushReplacement/replace) are included when
///     they are the visible leaf on the active Navigator.
class GoRouterRouteLifecycleService
    with ChangeNotifier, WidgetsBindingObserver {
  GoRouterRouteLifecycleService._(this._router, {this.fireOnlyLeaf = false}) {
    _prev = _router.routerDelegate.currentConfiguration;
    _router.routerDelegate.addListener(_handleDelegateChange);
    WidgetsBinding.instance.addObserver(this);
  }

  static GoRouterRouteLifecycleService? _instance;
  static GoRouterRouteLifecycleService? get instance => _instance;
  final GoRouter _router;
  RouteMatchList _prev = RouteMatchList.empty;
  final bool fireOnlyLeaf;

  /// Internal registry keyed by pageKey.value (String) for stable lookup.
  final Map<String, _RouteLifecycleEntry> _registry = HashMap();

  /// Initialize (call once after GoRouter creation).
  static GoRouterRouteLifecycleService init(
    GoRouter router, {
    bool fireOnlyLeaf = false,
  }) {
    return _instance ??= GoRouterRouteLifecycleService._(
      router,
      fireOnlyLeaf: fireOnlyLeaf,
    );
  }

  static GoRouterRouteLifecycleService get I {
    assert(
      _instance != null,
      'GoRouterRouteLifecycleService.init(router) must be called first',
    );
    return _instance!;
  }

  /// Register callbacks for the current page found via context.
  /// Will immediately invoke onShow if the page is already visible.
  void registerForContext({
    required BuildContext context,
    PageShowCallback? onPageShow,
    PageHideCallback? onPageHide,
    PageForegroundCallback? onForeground,
    PageBackgroundCallback? onBackground,
  }) {
    try {
      final GoRouterState state = GoRouterState.of(context);
      register(
        pageKey: state.pageKey.value,
        onPageShow: onPageShow,
        onPageHide: onPageHide,
        onForeground: onForeground,
        onBackground: onBackground,
        initialState: state,
        isInitiallyVisible: isStateVisible(state),
      );
    } catch (e) {
      debugPrint('Failed to register callbacks for context: $e');
      rethrow;
    }
  }

  void register({
    required String pageKey,
    PageShowCallback? onPageShow,
    PageHideCallback? onPageHide,
    PageForegroundCallback? onForeground,
    PageBackgroundCallback? onBackground,
    GoRouterState? initialState,
    bool isInitiallyVisible = false,
  }) {
    final _RouteLifecycleEntry entry = _registry.putIfAbsent(
      pageKey,
      () => _RouteLifecycleEntry(pageKey),
    );
    // Add callbacks, avoiding duplicates by checking if already present
    // Note: Function equality in Dart compares by reference, so same function
    // instances will be correctly identified as duplicates
    if (onPageShow != null && !entry.onPageShowCallbacks.contains(onPageShow)) {
      entry.onPageShowCallbacks.add(onPageShow);
    }
    if (onPageHide != null && !entry.onPageHideCallbacks.contains(onPageHide)) {
      entry.onPageHideCallbacks.add(onPageHide);
    }
    if (onForeground != null &&
        !entry.onForegroundCallbacks.contains(onForeground)) {
      entry.onForegroundCallbacks.add(onForeground);
    }
    if (onBackground != null &&
        !entry.onBackgroundCallbacks.contains(onBackground)) {
      entry.onBackgroundCallbacks.add(onBackground);
    }
    if (isInitiallyVisible && initialState != null && onPageShow != null) {
      // Fire initial show for newly registered callback.
      onPageShow(initialState);
    }
  }

  void unregisterCallback(
    String pageKey,
    PageShowCallback? onShow,
    PageHideCallback? onHide, [
    PageForegroundCallback? onForeground,
    PageBackgroundCallback? onBackground,
  ]) {
    final _RouteLifecycleEntry? entry = _registry[pageKey];
    if (entry == null) return;
    entry.onPageShowCallbacks.remove(onShow);
    entry.onPageHideCallbacks.remove(onHide);
    entry.onForegroundCallbacks.remove(onForeground);
    entry.onBackgroundCallbacks.remove(onBackground);
    if (entry.onPageShowCallbacks.isEmpty &&
        entry.onPageHideCallbacks.isEmpty &&
        entry.onForegroundCallbacks.isEmpty &&
        entry.onBackgroundCallbacks.isEmpty) {
      _registry.remove(pageKey);
    }
  }

  void disposeService() {
    _router.routerDelegate.removeListener(_handleDelegateChange);
    WidgetsBinding.instance.removeObserver(this);
    _registry.clear();
    // Close the stream controller to prevent resource leaks
    if (!_eventsController.isClosed) {
      _eventsController.close();
    }
    _instance = null;
  }

  void _handleDelegateChange() {
    // Guard against calls after dispose
    if (_instance == null) return;

    final RouteMatchList current = _router.routerDelegate.currentConfiguration;
    if (identical(current, _prev)) return;

    final List<RouteMatchBase> prevVisible = _visibleMatches(_prev);
    final List<RouteMatchBase> currVisible = _visibleMatches(current);

    final Map<String, GoRouterState> prevStates = {
      for (final m in prevVisible) _matchKey(m): _safeBuildState(m, _prev),
    };
    final Map<String, GoRouterState> currStates = {
      for (final m in currVisible) _matchKey(m): _safeBuildState(m, current),
    };

    // Hidden
    for (final key in prevStates.keys) {
      if (!currStates.containsKey(key)) {
        _fireHide(prevStates[key]!);
      }
    }
    // Shown
    for (final key in currStates.keys) {
      if (!prevStates.containsKey(key)) {
        _fireShow(currStates[key]!);
      }
    }
    _prev = current;
  }

  void _fireShow(GoRouterState state) {
    _emit(
      RouteLifecycleEvent(type: RouteLifecycleEventType.show, state: state),
    );
    final _RouteLifecycleEntry? entry = _registry[state.pageKey.value];
    if (entry == null) return;
    for (final cb in entry.onPageShowCallbacks) {
      try {
        cb(state);
      } catch (e, stackTrace) {
        // Log error but don't let one callback's exception affect others
        debugPrint('Error in onShow callback: $e\n$stackTrace');
      }
    }
  }

  void _fireHide(GoRouterState state) {
    _emit(
      RouteLifecycleEvent(type: RouteLifecycleEventType.hide, state: state),
    );
    final _RouteLifecycleEntry? entry = _registry[state.pageKey.value];
    if (entry == null) return;
    for (final cb in entry.onPageHideCallbacks) {
      try {
        cb(state);
      } catch (e, stackTrace) {
        // Log error but don't let one callback's exception affect others
        debugPrint('Error in onHide callback: $e\n$stackTrace');
      }
    }
  }

  void _fireAppForegroundForVisible() {
    // Guard against calls after dispose
    if (_instance == null) return;

    final RouteMatchList current = _router.routerDelegate.currentConfiguration;
    final List<RouteMatchBase> currVisible = _visibleMatches(current);
    for (final m in currVisible) {
      final GoRouterState s = _safeBuildState(m, current);
      _emit(
        RouteLifecycleEvent(type: RouteLifecycleEventType.foreground, state: s),
      );
      final _RouteLifecycleEntry? entry = _registry[s.pageKey.value];
      if (entry == null) continue;
      for (final cb in entry.onForegroundCallbacks) {
        try {
          cb(s);
        } catch (e, stackTrace) {
          // Log error but don't let one callback's exception affect others
          debugPrint('Error in onForeground callback: $e\n$stackTrace');
        }
      }
    }
  }

  void _fireAppBackgroundForVisible() {
    // Guard against calls after dispose
    if (_instance == null) return;

    final RouteMatchList current = _router.routerDelegate.currentConfiguration;
    final List<RouteMatchBase> currVisible = _visibleMatches(current);
    for (final m in currVisible) {
      final GoRouterState s = _safeBuildState(m, current);
      _emit(
        RouteLifecycleEvent(type: RouteLifecycleEventType.background, state: s),
      );
      final _RouteLifecycleEntry? entry = _registry[s.pageKey.value];
      if (entry == null) continue;
      for (final cb in entry.onBackgroundCallbacks) {
        try {
          cb(s);
        } catch (e, stackTrace) {
          // Log error but don't let one callback's exception affect others
          debugPrint('Error in onBackground callback: $e\n$stackTrace');
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _fireAppForegroundForVisible();

      case AppLifecycleState.paused:
        _fireAppBackgroundForVisible();

      case AppLifecycleState.detached:
        // Detached: App is about to be terminated by the system
        // - iOS: Rarely triggered (app termination)
        // - Android: Triggered when system is about to kill the app
        // - Web/Desktop: Triggered when window is about to close
        _handleDetached();

      case AppLifecycleState.hidden:
        // Hidden: App window is hidden (web/desktop only)
        // - iOS: Not available
        // - Android: Not available
        // - Web/Desktop: Triggered when window/tab is hidden
        if (kIsWeb || _isDesktop()) {
          _handleHidden();
        }

      case AppLifecycleState.inactive:
        // Inactive: App is in transition between states
        // - iOS: Triggered when receiving calls, notifications, etc.
        // - Android: Rarely triggered
        // - Web/Desktop: Triggered when window loses focus
        _handleInactive();
    }
  }

  /// Handle detached state (app about to be terminated).
  /// This is platform-specific:
  /// - iOS: Rarely triggered
  /// - Android: System is killing the app
  /// - Web/Desktop: Window is closing
  void _handleDetached() {
    // On Android, detached usually means the app is being killed
    // We might want to fire background callbacks as a last chance
    if (!kIsWeb && _isAndroid()) {
      _fireAppBackgroundForVisible();
    }
    // On web/desktop, detached means window is closing
    // We might want to save state or fire background callbacks
    if (kIsWeb || _isDesktop()) {
      _fireAppBackgroundForVisible();
    }
  }

  /// Handle hidden state (web/desktop only).
  /// Triggered when window/tab is hidden.
  void _handleHidden() {
    // On web/desktop, hidden means the window/tab is not visible
    // Treat it similar to background
    _fireAppBackgroundForVisible();
  }

  /// Handle inactive state (transition state).
  /// This is platform-specific:
  /// - iOS: Common (calls, notifications, control center)
  /// - Android: Rare
  /// - Web/Desktop: Window loses focus
  void _handleInactive() {
    // On iOS, inactive is a transient state that often precedes paused
    // We typically don't need to do anything special here
    // On web/desktop, inactive might mean window lost focus but is still visible
    // We might want to pause some operations but not treat it as background

    // For now, we ignore inactive as it's usually transient
    // But you can add platform-specific logic here if needed
    if (kIsWeb || _isDesktop()) {
      // On desktop/web, inactive might mean window lost focus
      // You might want to pause animations or reduce activity
      // but not fire background callbacks
    }
  }

  /// Check if running on desktop platform (macOS, Windows, Linux).
  bool _isDesktop() {
    if (kIsWeb) return false;
    try {
      // Access Platform static properties directly
      // Note: This will only work on non-web platforms
      return io.Platform.isMacOS ||
          io.Platform.isWindows ||
          io.Platform.isLinux;
    } catch (_) {
      // If Platform is not available (e.g., on web), return false
      return false;
    }
  }

  /// Check if running on Android.
  bool _isAndroid() {
    if (kIsWeb) return false;
    try {
      // Access Platform static properties directly
      return io.Platform.isAndroid;
    } catch (_) {
      // If Platform is not available (e.g., on web), return false
      return false;
    }
  }

  /// Check if a state is currently visible.
  /// Made public for use by mixins and widgets.
  bool isStateVisible(GoRouterState state) {
    final List<RouteMatchBase> currentVisible = _visibleMatches(
      _router.routerDelegate.currentConfiguration,
    );
    return currentVisible.any((m) => state.pageKey.value == m.pageKey.value);
  }

  /// Check if a page with given pageKey is visible (respects fireOnlyLeaf).
  bool isPageVisible(String pageKey) {
    final List<RouteMatchBase> currentVisible = _visibleMatches(
      _router.routerDelegate.currentConfiguration,
    );
    return currentVisible.any((m) => pageKey == m.pageKey.value);
  }

  /// Get the GoRoute for a given pageKey from the current configuration.
  /// Returns null if the page is not found in the current route configuration.
  GoRoute? getRouteForPageKey(String pageKey) {
    final RouteMatchList current = _router.routerDelegate.currentConfiguration;
    final List<RouteMatchBase> allMatches = _getAllMatches(current);

    for (final match in allMatches) {
      if (match.pageKey.value == pageKey && match is RouteMatch) {
        return match.route;
      }
    }
    return null;
  }

  /// Get the GoRoute for a given GoRouterState.
  ///
  /// This is a convenience method that returns state.topRoute.
  /// Note: topRoute may be null in some cases:
  /// - For ShellRoute matches
  /// - For error routes
  /// - For top-level redirects
  ///
  /// If topRoute is null, you can use other properties like:
  /// - state.uri.path - the current path
  /// - state.pageKey.value - the page key
  /// - state.name - the route name (if available)
  GoRoute? getRouteForState(GoRouterState state) {
    return state.topRoute;
  }

  /// Get the GoRoute for the currently visible page with the given pageKey.
  /// Returns null if the page is not currently visible.
  GoRoute? getRouteForVisiblePage(String pageKey) {
    final List<RouteMatchBase> currentVisible = _visibleMatches(
      _router.routerDelegate.currentConfiguration,
    );

    for (final match in currentVisible) {
      if (match.pageKey.value == pageKey && match is RouteMatch) {
        return match.route;
      }
    }
    return null;
  }

  /// Get the top-level (leaf) visible GoRoute.
  /// This returns the route at the top of the visible route stack.
  /// Returns null if there are no visible routes.
  ///
  /// This is useful for getting the current page route when showing dialogs,
  /// bottom sheets, or other overlays, as the underlying page remains visible.
  ///
  /// Example for dialog tracking:
  /// ```dart
  /// void showMyDialog() {
  ///   final topRoute = GoRouterRouteLifecycleService.I.getTopVisibleRoute();
  ///   final pageName = topRoute?.name ?? 'unknown';
  ///
  ///   showDialog(
  ///     context: context,
  ///     builder: (context) => MyDialog(),
  ///   );
  ///
  ///   // Track dialog shown with current page context
  ///   logEvent('dialog_shown', {
  ///     'dialog_name': 'my_dialog',
  ///     'current_page': pageName,
  ///   });
  /// }
  /// ```
  GoRoute? getTopVisibleRoute() {
    final List<RouteMatchBase> currentVisible = _visibleMatches(
      _router.routerDelegate.currentConfiguration,
    );

    if (currentVisible.isEmpty) return null;

    // Get the last (topmost/leaf) match
    final RouteMatchBase topMatch = currentVisible.last;
    if (topMatch is RouteMatch) {
      return topMatch.route;
    }

    return null;
  }

  /// Get all RouteMatchBase instances from the current configuration.
  /// This includes both visible and non-visible matches.
  List<RouteMatchBase> _getAllMatches(RouteMatchList list) {
    final List<RouteMatchBase> out = <RouteMatchBase>[];
    if (list.isEmpty) return out;

    void collect(List<RouteMatchBase> matches) {
      for (final match in matches) {
        out.add(match);
        if (match is ShellRouteMatch) {
          collect(match.matches);
        }
      }
    }

    collect(list.matches);
    return out;
  }

  GoRouterState _safeBuildState(RouteMatchBase m, RouteMatchList list) {
    try {
      return m.buildState(_router.configuration, list);
    } catch (_) {
      // Fallback minimal state (should rarely happen)
      return GoRouterState(
        _router.configuration,
        uri: list.uri,
        matchedLocation: m.matchedLocation,
        fullPath: list.fullPath,
        pathParameters: list.pathParameters,
        pageKey: m.pageKey,
        topRoute: m is RouteMatch ? m.route : null,
      );
    }
  }

  String _matchKey(RouteMatchBase m) =>
      '${m.route.hashCode}|${m.pageKey.value}|${m.matchedLocation}';

  List<RouteMatchBase> _visiblePath(RouteMatchList list) {
    final List<RouteMatchBase> out = <RouteMatchBase>[];
    if (list.isEmpty) return out;
    void descend(List<RouteMatchBase> matches) {
      if (matches.isEmpty) return;
      final RouteMatchBase last = matches.last;
      out.add(last);
      if (last is ShellRouteMatch) {
        descend(last.matches);
      }
    }

    descend(list.matches);
    return out;
  }

  List<RouteMatchBase> _visibleMatches(RouteMatchList list) {
    final chain = _visiblePath(list);
    if (chain.isEmpty) return chain;
    return fireOnlyLeaf ? <RouteMatchBase>[chain.last] : chain;
  }

  // Event stream for optional global observers.
  final StreamController<RouteLifecycleEvent> _eventsController =
      StreamController<RouteLifecycleEvent>.broadcast();

  /// Global event stream for route lifecycle events.
  ///
  /// Use this stream to listen to all route lifecycle events globally.
  ///
  /// Example:
  /// ```dart
  /// GoRouterRouteLifecycleService.I.events.listen((event) {
  ///   switch (event.type) {
  ///     case RouteLifecycleEventType.show:
  ///       // Track page view
  ///       analytics.trackPageView(event.state.uri.toString());
  ///       break;
  ///     case RouteLifecycleEventType.hide:
  ///       // Track page leave
  ///       analytics.trackPageLeave(event.state.uri.toString());
  ///       break;
  ///     case RouteLifecycleEventType.foreground:
  ///       // Track app foreground
  ///       analytics.trackAppForeground();
  ///       break;
  ///     case RouteLifecycleEventType.background:
  ///       // Track app background
  ///       analytics.trackAppBackground();
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<RouteLifecycleEvent> get events => _eventsController.stream;

  void _emit(RouteLifecycleEvent e) {
    if (!_eventsController.isClosed && _eventsController.hasListener) {
      try {
        _eventsController.add(e);
      } catch (error) {
        // Log error but don't throw - stream may have been closed
        debugPrint('Error emitting route lifecycle event: $error');
      }
    }
  }
}

class _RouteLifecycleEntry {
  _RouteLifecycleEntry(this.pageKey);
  final String pageKey;
  final List<PageShowCallback> onPageShowCallbacks = <PageShowCallback>[];
  final List<PageHideCallback> onPageHideCallbacks = <PageHideCallback>[];
  final List<PageForegroundCallback> onForegroundCallbacks =
      <PageForegroundCallback>[];
  final List<PageBackgroundCallback> onBackgroundCallbacks =
      <PageBackgroundCallback>[];
}

/// Mixin for a StatefulWidget's State to receive route lifecycle callbacks.
mixin GoRouterRouteLifecycleMixin<T extends StatefulWidget> on State<T> {
  GoRouterState? _state;
  bool _registered = false;

  void onPageShow(GoRouterState state) {}
  void onPageHide(GoRouterState state) {}
  void onForeground(GoRouterState state) {}
  void onBackground(GoRouterState state) {}

  @override
  void initState() {
    super.initState();
    withRouteLifecycleInit();
  }

  @protected
  @mustCallSuper
  void withRouteLifecycleInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Safely get GoRouterState, handle potential exceptions
      try {
        _state = GoRouterState.of(context);
      } catch (e) {
        debugPrint(
          'Failed to get GoRouterState in GoRouterRouteLifecycleMixin: $e',
        );
        return;
      }

      if (_state == null) return;

      // Guard against service being disposed
      final service = GoRouterRouteLifecycleService._instance;
      if (service == null) return;

      service.register(
        pageKey: _state!.pageKey.value,
        onPageShow: onPageShow,
        onPageHide: onPageHide,
        onForeground: onForeground,
        onBackground: onBackground,
        initialState: _state,
        isInitiallyVisible: service.isStateVisible(_state!),
      );
      _registered = true;
    });
  }

  @override
  void dispose() {
    if (_registered && _state != null) {
      // Guard against service being disposed
      final service = GoRouterRouteLifecycleService._instance;
      if (service != null) {
        service.unregisterCallback(
          _state!.pageKey.value,
          onPageShow,
          onPageHide,
          onForeground,
          onBackground,
        );
      }
    }
    super.dispose();
  }
}

/// Convenience widget wrapper for pages built via GoRoute.builder.
class GoRouterRouteLifecycleWidget extends StatefulWidget {
  const GoRouterRouteLifecycleWidget({
    super.key,
    required this.child,
    this.onPageShow,
    this.onPageHide,
    this.onForeground,
    this.onBackground,
  });
  final Widget child;
  final PageShowCallback? onPageShow;
  final PageHideCallback? onPageHide;
  final PageForegroundCallback? onForeground;
  final PageBackgroundCallback? onBackground;
  @override
  State<GoRouterRouteLifecycleWidget> createState() =>
      _GoRouterRouteLifecycleWidgetState();
}

class _GoRouterRouteLifecycleWidgetState
    extends State<GoRouterRouteLifecycleWidget> {
  GoRouterState? _state;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Safely get GoRouterState, handle potential exceptions
      try {
        _state = GoRouterState.of(context);
      } catch (e) {
        debugPrint(
          'Failed to get GoRouterState in GoRouterRouteLifecycleWidget: $e',
        );
        return;
      }

      if (_state == null) return;

      // Guard against service being disposed
      final service = GoRouterRouteLifecycleService._instance;
      if (service == null) return;

      service.register(
        pageKey: _state!.pageKey.value,
        onPageShow: widget.onPageShow,
        onPageHide: widget.onPageHide,
        onForeground: widget.onForeground,
        onBackground: widget.onBackground,
        initialState: _state,
        isInitiallyVisible: service.isStateVisible(_state!),
      );
      _registered = true;
    });
  }

  @override
  void dispose() {
    if (_registered && _state != null) {
      // Guard against service being disposed
      final service = GoRouterRouteLifecycleService._instance;
      if (service != null) {
        service.unregisterCallback(
          _state!.pageKey.value,
          widget.onPageShow,
          widget.onPageHide,
          widget.onForeground,
          widget.onBackground,
        );
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
