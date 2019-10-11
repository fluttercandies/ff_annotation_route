Type typeOf<T>() => T;

const String fileHeader = """// GENERATED CODE - DO NOT MODIFY BY HAND
// **************************************************************************
// auto generated by https://github.com/fluttercandies/ff_annotation_route
// ************************************************************************** \n""";

const String rootFile = """

RouteResult getRouteResult({String name, Map<String, dynamic> arguments}) {
  arguments??={};
  switch (name) {
{0}   default:
      return RouteResult();
  }
}

class RouteResult {
  /// The Widget return base on route
  final Widget widget;

  /// Whether show this route with status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  const RouteResult(
      {this.widget,
      this.showStatusBar = true,
      this.routeName = '',
      this.pageRouteType,
      this.description = ''});
}

 enum PageRouteType { material, cupertino, transparent }
""";

const String routeHelper = """
import 'package:flutter/widgets.dart';

class FFNavigatorObserver extends NavigatorObserver {
  final ShowStatusBarChange showStatusBarChange;
  final RouteChange routeChange;

  FFNavigatorObserver({this.showStatusBarChange, this.routeChange});

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);    
    _showStatusBarChange(previousRoute, route);
    _routeChange(previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    _showStatusBarChange(route, previousRoute);
    _routeChange(route);
  }

  @override
  void didRemove(Route route, Route previousRoute) {
     super.didRemove(route, previousRoute);
    _showStatusBarChange(previousRoute, route);
    _routeChange(previousRoute);  
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
     super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _showStatusBarChange(newRoute, oldRoute);
    _routeChange(newRoute);
  }

  @override
  void didStartUserGesture(Route route, Route previousRoute) {
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
  }

  void _showStatusBarChange(Route newRoute, Route oldRoute) {
    if (showStatusBarChange != null) {
      var newSettting = getFFRouteSettings(newRoute);
      var oldSetting = getFFRouteSettings(oldRoute);
      if (newSettting?.showStatusBar != null &&
          newSettting.showStatusBar != oldSetting?.showStatusBar) {
        showStatusBarChange(newSettting.showStatusBar);
      }
    }
  }

  void _routeChange(Route newRoute) {
    if (routeChange != null) {
      var newSettting = getFFRouteSettings(newRoute);
      if (newSettting?.routeName != null) {
        routeChange(newSettting.routeName);
      }
    }
  }

  FFRouteSettings getFFRouteSettings(Route route) {
    if (route != null &&
        route.settings != null &&
        route.settings is FFRouteSettings) {
      return route.settings;
    }
    return null;
  }
}

typedef ShowStatusBarChange = void Function(bool showStatusBar);

typedef RouteChange = void Function(String routeName);

class FFTransparentPageRoute<T> extends PageRouteBuilder<T> {
  FFTransparentPageRoute({
    RouteSettings settings,
    @required RoutePageBuilder pageBuilder,
    RouteTransitionsBuilder transitionsBuilder = _defaultTransitionsBuilder,
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = false,
    Color barrierColor,
    String barrierLabel,
    bool maintainState = true,
  })  : assert(pageBuilder != null),
        assert(transitionsBuilder != null),
        assert(barrierDismissible != null),
        assert(maintainState != null),
        super(
            settings: settings,
            opaque: false,
            pageBuilder: pageBuilder,
            transitionsBuilder: transitionsBuilder,
            transitionDuration: transitionDuration,
            barrierDismissible: barrierDismissible,
            barrierColor: barrierColor,
            barrierLabel: barrierLabel,
            maintainState: maintainState);
}

Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return child;
}

""";

const String ffRouteSettings = """
class FFRouteSettings extends RouteSettings {
  final String routeName;
  final bool showStatusBar;
  const FFRouteSettings({
    this.routeName,
    this.showStatusBar,
    String name,
    bool isInitialRoute = false,
    Object arguments,
  }) : super(name: name, isInitialRoute: isInitialRoute, arguments: arguments);
}
""";

const String ffRouteSettingsNoArguments = """
class FFRouteSettings extends RouteSettings {
  final String routeName;
  final bool showStatusBar;
  const FFRouteSettings({
    this.routeName,
    this.showStatusBar,
    String name,
    bool isInitialRoute = false,
  }) : super(name: name, isInitialRoute: isInitialRoute);
}
""";
