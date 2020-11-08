/*
 * @Author: zmtzawqlp
 * @Date: 2020-11-08 16:22:44
 * @Last Modified by: zmtzawqlp
 * @Last Modified time: 2020-11-08 16:54:21
 */

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package_graph.dart';
import 'route_info.dart';
import 'utils.dart';
import 'utils/convert.dart';
import 'utils/format.dart';

class RoutesFileGenerator {
  RoutesFileGenerator({
    this.generateRouteConstants,
    this.generateRouteNames,
    this.enableSupperArguments,
    this.routesFileOutputPath,
    this.routes,
    this.lib,
    this.packageNode,
  });
  final bool generateRouteConstants;
  final String routesFileOutputPath;
  final bool generateRouteNames;
  final List<RouteInfo> routes;
  final bool enableSupperArguments;
  final Directory lib;
  final PackageNode packageNode;

  void generateRoutesFile() {
    if (generateRouteConstants || generateRouteNames) {
      final StringBuffer constantsSb = StringBuffer();
      final String name = '${packageNode.name}_routes.dart';
      String routePath;

      if (routesFileOutputPath != null) {
        routePath = p.join(lib.path, routesFileOutputPath, name);
      } else {
        routePath = p.join(lib.path, name);
      }

      final File file = File(routePath);
      if (file.existsSync()) {
        file.deleteSync();
      }

      if (generateRouteNames) {
        //constantsSb.write(fileHeader);

        final StringBuffer routeNamesString = StringBuffer();
        for (final RouteInfo item in routes) {
          routeNamesString.write(safeToString(item.ffRoute.name));
          routeNamesString.write(',');
        }

        constantsSb.write(
            'const List<String> routeNames = <String>[${routeNamesString.toString()}];');
        constantsSb.write('\n');
      }
      final List<String> imports = <String>[];
      if (generateRouteConstants) {
        if (constantsSb.isEmpty) {
          constantsSb.write(fileHeader);
        }
        constantsSb.write('class Routes {\n');
        constantsSb.write('const Routes._();\n');
        for (final RouteInfo it in routes) {
          it.getRouteConst(enableSupperArguments, constantsSb);
        }
        constantsSb.write('}');

        if (enableSupperArguments) {
          for (final RouteInfo it in routes) {
            if (it.argumentsClass != null) {
              constantsSb.write(it.argumentsClass);
              if (it.argumentsClass.contains('@required')) {
                if (!imports.contains(requiredS)) {
                  imports.add(requiredS);
                }
              }
              if (it.ffRoute.argumentImports != null &&
                  it.ffRoute.argumentImports.isNotEmpty) {
                for (final String item in it.ffRoute.argumentImports) {
                  if (!imports.contains(item)) {
                    imports.add('$item');
                  }
                }
              }
            }
          }
        }
      }

      String constants;

      if (constantsSb.isNotEmpty) {
        constants = constantsSb.toString();

        if (imports.isNotEmpty) {
          final StringBuffer sb = StringBuffer();
          writeImports(imports, sb);
          constants = sb.toString() + constants;
        }
        constants = fileHeader + constants;
      }

      if (constants != null) {
        file.createSync(recursive: true);
        file.writeAsStringSync(formatDart(constants));
        print('Generate : ${p.relative(file.path, from: packageNode.path)}');
      }
    }
  }
}

const String requiredS = 'import \'package:flutter/foundation.dart\';';
