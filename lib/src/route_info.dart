import 'dart:convert';

import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'utils/convert.dart';

class RouteInfo {
  RouteInfo({this.ffRoute, this.className});

  final String className;
  final FFRoute ffRoute;

  String get constructor {
    String params = '';
    if (ffRoute.argumentNames != null && ffRoute.argumentNames.isNotEmpty) {
      for (final String key in ffRoute.argumentNames) {
        params +=
            '${key.replaceAll('\'', '').replaceAll('\"', '')}:arguments[${safeToString(key)}],';
      }
    }
    return '$className($params)';
  }

  String get caseString {
    return 'case ${safeToString(ffRoute.name)}: return RouteResult(name: name, widget: $constructor, ${ffRoute.showStatusBar != null ? 'showStatusBar: ${ffRoute.showStatusBar},' : ''} ${ffRoute.routeName != null ? 'routeName: ${safeToString(ffRoute.routeName)},' : ''} ${ffRoute.pageRouteType != null ? 'pageRouteType: ${ffRoute.pageRouteType},' : ''} ${ffRoute.description != null ? 'description: ${safeToString(ffRoute.description)},' : ''} ${ffRoute.exts != null ? 'exts:<String,dynamic>${json.encode(ffRoute.exts)},'.replaceAll('"', '\'') : ''});\n';
  }

  @override
  String toString() {
    return 'RouteInfo {className: $className, ffRoute: $ffRoute}';
  }
}
