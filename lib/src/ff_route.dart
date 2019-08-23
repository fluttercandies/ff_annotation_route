/// annotation to generate route
///
///
class FFRoute {
  /// The name of the route (e.g., "/settings").
  ///
  /// If null, the route is anonymous.
  final String name;

  /// The argument names passed to  FFRoute.
  final List<String> argumentNames;

  /// Whether show status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  const FFRoute(
      {String name,
      this.argumentNames,
      this.showStatusBar = true,
      this.routeName = '',
      this.pageRouteType,
      this.description = ''})
      : assert(name != null),
        this.name = name;
}

enum PageRouteType { material, cupertino, transparent }
