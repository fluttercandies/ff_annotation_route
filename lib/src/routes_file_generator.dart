/*
 * @Author: zmtzawqlp
 * @Date: 2020-11-08 16:22:44
 * @Last Modified by: zmtzawqlp
 * @Last Modified time: 2020-11-08 16:54:21
 */

import 'dart:io';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route/src/route_info/route_info_base.dart';
import 'package:ff_annotation_route/src/utils/camel_under_score_converter.dart';
import 'package:ff_annotation_route/src/utils/dart_type_auto_import.dart';
import 'package:path/path.dart' as p;
import 'file_info.dart';
import 'template.dart';
import 'utils/convert.dart';
import 'utils/format.dart';

class RoutesFileGenerator {
  RoutesFileGenerator({
    this.routes,
    required this.lib,
    required this.packageName,
  });

  final List<RouteInfoBase>? routes;
  final Directory lib;
  final String packageName;

  void generateRoutesFile() {
    final RegExp? constIgnore = Args().constIgnoreRegExp;
    final StringBuffer constantsSb = StringBuffer();
    final File file =
        RoutesFileGenerator.deleteFile(packageName: packageName, lib: lib);

    //constantsSb.write(fileHeader);

    final StringBuffer routeNamesString = StringBuffer();
    for (final RouteInfoBase item in routes!) {
      if (constIgnore != null && constIgnore.hasMatch(item.ffRoute.name)) {
        continue;
      }
      routeNamesString.write(safeToString(item.ffRoute.name));
      routeNamesString.write(',');
    }
    String routeNames = 'routeNames';
    if (Args().isPackage) {
      routeNames = '${camelName(packageName)}RouteNames';
    }
    constantsSb.write(
        '/// The routeNames auto generated by https://github.com/fluttercandies/ff_annotation_route\n');
    constantsSb.write(
        'const List<String> $routeNames = <String>[${routeNamesString.toString()}];');
    constantsSb.write('\n');

    final Set<String> imports = <String>{};

    if (constantsSb.isEmpty) {
      constantsSb.write(fileHeader);
    }
    final String? className = Args().className;
    constantsSb.write(
        '/// The routes auto generated by https://github.com/fluttercandies/ff_annotation_route\n');
    constantsSb.write('class $className {\n');
    constantsSb.write('const $className._();\n');

    final bool enableSuperArguments = Args().enableSuperArguments;
    for (final RouteInfoBase it in routes!) {
      if (constIgnore != null && constIgnore.hasMatch(it.ffRoute.name)) {
        continue;
      }
      it.getRouteConst(enableSuperArguments, constantsSb);
    }
    constantsSb.write('}');

    if (enableSuperArguments) {
      for (final RouteInfoBase it in routes!) {
        if (it.argumentsClass != null) {
          if (constIgnore != null && constIgnore.hasMatch(it.ffRoute.name)) {
            continue;
          }
          constantsSb.write(it.argumentsClass);
          if (!Args().enableNullSafety &&
              it.argumentsClass!.contains('@required')) {
            imports.add(requiredS);
          }
          if (it.argumentsClass!.contains('Key')) {
            imports.add(requiredS);
          }
          if (it.ffRoute.argumentImports != null &&
              it.ffRoute.argumentImports!.isNotEmpty) {
            imports.addAll(it.ffRoute.argumentImports!);
          }
        }
      }
      imports.addAll(DartTypeAutoImportHelper().imports);
      imports.addAll(FileInfo.imports);
    }

    String? constants;

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
      print('Generate : ${p.relative(file.path, from: lib.parent.path)}');
    }
  }

  static File deleteFile(
      {required String packageName, required Directory lib}) {
    final String? routesFileOutputPath = Args().routesFileOutputPath;

    final String name = '${packageName}_routes.dart';
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
    return file;
  }
}

const String requiredS = 'import \'package:flutter/foundation.dart\';';
