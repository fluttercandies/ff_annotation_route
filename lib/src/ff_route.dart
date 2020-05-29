/// Annotation to generate route
import 'package:meta/meta.dart';

class FFRoute {
  const FFRoute({
    @required this.name,
    this.argumentNames,
    this.showStatusBar = true,
    this.routeName = '',
    this.pageRouteType,
    this.description = '',
    this.exts,
    this.argumentTypes,
  }) : assert(name != null);

  /// The name of the route (e.g., "/settings").
  ///
  /// If null, the route is anonymous.
  final String name;

  /// The argument names passed to FFRoute.
  final List<String> argumentNames;

  /// Whether show status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  /// The extend arguments
  final Map<String, dynamic> exts;

  /// The types of arguments.
  ///
  /// It's easily to see type of argument from Route Constants
  ///
  /// "This is test page B."
  ///
  /// [name] : flutterCandies://testPageB
  ///
  /// [routeName] : testPageB
  ///
  /// [description] : "This is test page B."
  ///
  /// [arguments] : [argument]
  ///
  /// [argumentTypes] : [String]
  ///
  /// [exts] : {test: 1, test1: string}
  /// static const String flutterCandiesTestPageB = 'flutterCandies://testPageB';
  final List<String> argumentTypes;

  @override
  String toString() {
    return 'FFRoute{name: $name, argumentNames: $argumentNames, showStatusBar: $showStatusBar, routeName: $routeName, pageRouteType: $pageRouteType, description: $description,exts: $exts,argumentTypes:$argumentTypes,}';
  }
}

enum PageRouteType { material, cupertino, transparent }
