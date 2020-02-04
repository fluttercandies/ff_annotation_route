import 'package:ff_annotation_route/ff_annotation_route.dart';

class RouteInfo {
  final String className;
  final FFRoute ffRoute;
  RouteInfo({this.ffRoute, this.className});

  String get constructor {
    String params;
    if (ffRoute.argumentNames != null && ffRoute.argumentNames.isNotEmpty) {
      for (final key in ffRoute.argumentNames) {
        params ??= '';
        params += "$key:arguments['$key'],";
      }
    } else {
      params = '';
    }

    return '$className($params)';
  }

  String get caseString {
    return """    case ${ffRoute.name}:
      return RouteResult(widget: $constructor, ${ffRoute.showStatusBar != null ? 'showStatusBar: ${ffRoute.showStatusBar},' : ''} ${ffRoute.routeName != null ? 'routeName: ${ffRoute.routeName},' : ''} ${ffRoute.pageRouteType != null ? 'pageRouteType: ${ffRoute.pageRouteType},' : ''} ${ffRoute.description != null ? 'description: ${ffRoute.description},' : ''});\n""";
  }

  @override
  String toString() {
    return 'RouteInfo{className: $className, ffRoute: $ffRoute}';
  }
}
