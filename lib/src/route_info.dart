import 'dart:convert';

import 'package:ff_annotation_route/ff_annotation_route.dart';

class RouteInfo {
  RouteInfo({this.ffRoute, this.className});

  final String className;
  final FFRoute ffRoute;

  String get constructor {
    String params;
    if (ffRoute.argumentNames != null && ffRoute.argumentNames.isNotEmpty) {
      for (final String key in ffRoute.argumentNames) {
        params ??= '';
        params += "$key:arguments['$key'],";
      }
    } else {
      params = '';
    }

    return '$className($params)';
  }

  String get caseString {
    return '''    case ${ffRoute.name}:
      return RouteResult(widget: $constructor, ${ffRoute.showStatusBar != null ? 'showStatusBar: ${ffRoute.showStatusBar},' : ''} ${ffRoute.routeName != null ? 'routeName: ${ffRoute.routeName},' : ''} ${ffRoute.pageRouteType != null ? 'pageRouteType: ${ffRoute.pageRouteType},' : ''} ${ffRoute.description != null ? 'description: ${ffRoute.description},' : ''} ${ffRoute.exts != null ? 'exts:<String,dynamic>${json.encode(ffRoute.exts)},' : ''});\n''';
  }

  @override
  String toString() {
    return 'RouteInfo {className: $className, ffRoute: $ffRoute}';
  }
}
