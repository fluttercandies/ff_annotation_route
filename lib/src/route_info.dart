import 'package:ff_annotation_route/ff_annotation_route.dart';

class RouteInfo {
  final String className;
  final FFRoute ffRoute;
  RouteInfo({this.ffRoute, this.className});

  String get ctor {
    var params = "";
    if (ffRoute.argumentNames != null && ffRoute.argumentNames.isNotEmpty) {
      for (var key in ffRoute.argumentNames) {
        params += "$key:arguments??={}['$key'],";
      }
    }

    return "$className($params)";
  }

  String get caseString {
    return """    case ${ffRoute.name}:
      return RouteResult(widget: $ctor, ${ffRoute.showStatusBar != null ? 'showStatusBar: ${ffRoute.showStatusBar},' : ''} ${ffRoute.routeName != null ? 'routeName: ${ffRoute.routeName},' : ''} ${ffRoute.pageRouteType != null ? 'pageRouteType: ${ffRoute.pageRouteType},' : ''} ${ffRoute.description != null ? 'description: ${ffRoute.description},' : ''});\n""";
  }
}
