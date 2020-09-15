/// Annotation to generate route
import 'package:meta/meta.dart';

class FFRoute {
  const FFRoute({
    @required this.name,
    this.showStatusBar = true,
    this.routeName = '',
    this.pageRouteType,
    this.description = '',
    this.exts,
    this.argumentImports,
  }) : assert(name != null);

  /// The name of the route (e.g., "/settings").
  ///
  /// If null, the route is anonymous.
  final String name;

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

  /// The imports of arguments.
  /// For example, class/enum argument should provide import url.
  /// argumentImports: <String>[
  ///   'import \'package:example/src/model/test_model.dart\';',
  ///   'import \'package:example/src/model/test_model1.dart\';'
  /// ],
  final List<String> argumentImports;

  @override
  String toString() {
    return 'FFRoute{name: $name,  showStatusBar: $showStatusBar, routeName: $routeName, pageRouteType: $pageRouteType, description: $description,exts: $exts,argumentImports:$argumentImports,}';
  }
}

enum PageRouteType { material, cupertino, transparent }

const String constructorName = 'constructorName';
