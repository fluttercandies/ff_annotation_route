import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'ff_route.dart';
import 'file_info.dart';
import 'package_graph.dart';
import 'route_info.dart';
import 'routes_file_generator.dart';
import 'utils.dart';
import 'utils/convert.dart';
import 'utils/format.dart';

class RouteGenerator {
  RouteGenerator(this.packageNode, this.isRoot);

  final List<FileInfo> _fileInfoList = <FileInfo>[];

  List<FileInfo> get fileInfoList => _fileInfoList;

  Directory _lib;

  final PackageNode packageNode;
  final bool isRoot;

  bool get hasAnnotationRoute => _lib != null && _fileInfoList.isNotEmpty;

  String get import =>
      "import 'package:${packageNode.name}/${packageNode.name}_route.dart';";

  String get export {
    if (_fileInfoList.isNotEmpty) {
      final StringBuffer sb = StringBuffer();

      if (!isRoot) {
        sb.write('library ${packageNode.name}_route;\n');
      }

      _fileInfoList
          .sort((FileInfo a, FileInfo b) => a.export.compareTo(b.export));

      for (final FileInfo info in _fileInfoList) {
        sb.write("${isRoot ? "import" : "export"} '${info.export}'; \n");
      }
      return sb.toString();
    }
    return '';
  }

  void scanLib([String output]) {
    if (_lib != null) {
      print('');
      print('Scanning package : ${packageNode.name}');
      for (final FileSystemEntity item in _lib.listSync(recursive: true)) {
        final FileStat file = item.statSync();
        if (file.type == FileSystemEntityType.file &&
            item.path.endsWith('.dart')) {
          final CompilationUnit astRoot = parseFile(
            path: item.path,
            featureSet: FeatureSet.fromEnableFlags(<String>[]),
          ).unit;

          FileInfo fileInfo;
          for (final CompilationUnitMember declaration
              in astRoot.declarations) {
            for (final Annotation metadata in declaration.metadata) {
              if (metadata is AnnotationImpl &&
                  metadata.name?.name == typeOf<FFRoute>().toString() &&
                  metadata.parent is ClassDeclarationImpl) {
                final ClassDeclarationImpl parent =
                    metadata.parent as ClassDeclarationImpl;

                final String className = parent.name?.name;

                final String routePath =
                    '${p.relative(item.path, from: packageNode.path)} ------ class : $className';
                print('Found annotation route : $routePath');

                final List<String> relativeParts = <String>[
                  packageNode.path,
                  'lib'
                ];
                if (output != null) {
                  relativeParts.add(output);
                }

                fileInfo ??= FileInfo(
                    export: p
                        .relative(item.path, from: p.joinAll(relativeParts))
                        .replaceAll('\\', '/'),
                    packageName: packageNode.name);

                final NodeList<Expression> parameters =
                    metadata.arguments?.arguments;

                String name;
                bool showStatusBar;
                String routeName;
                PageRouteType pageRouteType;
                String description;
                Map<String, dynamic> exts;
                List<String> argumentImports;

                for (final Expression item in parameters) {
                  if (item is NamedExpressionImpl) {
                    String source;
                    source = item.expression.toSource();
                    if (source == 'null') {
                      continue;
                    }
                    final String key = item.name.toSource();

                    switch (key) {
                      case 'name:':
                        name = toT<String>(item.expression);
                        break;
                      case 'routeName:':
                        routeName = toT<String>(item.expression);
                        break;
                      case 'showStatusBar:':
                        showStatusBar = toT<bool>(item.expression);
                        break;
                      // case 'argumentNames:':
                      //   argumentNames = toT<List<String>>(item.expression);
                      //   break;
                      // case 'argumentTypes:':
                      //   argumentTypes = toT<List<String>>(item.expression);
                      //   break;
                      case 'pageRouteType:':
                        pageRouteType = PageRouteType.values.firstWhere(
                          (PageRouteType type) => type.toString() == source,
                          orElse: () => null,
                        );
                        break;
                      case 'description:':
                        description = toT<String>(item.expression);
                        break;
                      case 'argumentImports:':
                        argumentImports = toT<List<String>>(item.expression);
                        break;
                      case 'exts:':
                        source = source.substring(source.indexOf('{'));
                        source = source.replaceAll("'''", '\'');
                        source = source.replaceAll('"', '\'');
                        source = source.replaceAll('\'', '"');
                        exts = json.decode(source) as Map<String, dynamic>;
                        break;
                    }
                  }
                }

                final RouteInfo routeInfo = RouteInfo(
                  className: className,
                  ffRoute: FFRoute(
                    name: name,
                    showStatusBar: showStatusBar,
                    routeName: routeName,
                    pageRouteType: pageRouteType,
                    description: description,
                    exts: exts,
                    argumentImports: argumentImports ?? <String>[],
                  ),
                  constructors: parent.members
                      .whereType<ConstructorDeclaration>()
                      .toList(),
                  fields: parent.members.whereType<FieldDeclaration>().toList(),
                  routePath: routePath,
                  classDeclarationImpl: parent,
                );
                fileInfo.routes.add(routeInfo);
              }
            }
          }
          if (fileInfo != null) {
            _fileInfoList.add(fileInfo);
          }
        }
      }
    }
  }

  void getLib() {
    final Directory lib = Directory(p.join(packageNode.path, 'lib'));
    if (lib.existsSync()) {
      _lib = lib;
    }
  }

  void generateFile({
    List<RouteGenerator> nodes,
    bool generateRouteNames = false,
    bool generateRouteConstants = false,
    String outputPath,
    String routesFileOutputPath,
    bool enableSupperArguments = false,
  }) {
    final String name = '${packageNode.name}_route.dart';
    String routePath;
    if (outputPath != null) {
      routePath = p.join(_lib.path, outputPath, name);
    } else {
      routePath = p.join(_lib.path, name);
    }

    final File file = File(routePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (isRoot && _fileInfoList.isEmpty && (nodes?.isEmpty ?? true)) {
      return;
    }

    final StringBuffer sb = StringBuffer();

    final List<String> imports = <String>[];

    /// Nodes import
    if (isRoot && nodes != null && nodes.isNotEmpty) {
      for (final RouteGenerator node in nodes) {
        final String import = '${node.import}';
        if (!imports.contains(import)) {
          imports.add(import);
        }

        //sb.write('${node.import}\n');
      }
    }

    if (!isRoot) {
      /// Export
      sb.write(export);
    }

    /// Create route generator
    if (isRoot) {
      imports.add(export);
      imports.add('import \'package:flutter/widgets.dart\';');
      imports.add(
          'import \'package:ff_annotation_route/ff_annotation_route.dart\';');

      final StringBuffer caseSb = StringBuffer();
      final List<RouteInfo> routes = _fileInfoList
          .map((FileInfo it) => it.routes)
          .expand((List<RouteInfo> it) => it)
          .toList();
      if (nodes != null && nodes.isNotEmpty) {
        routes.addAll(
          nodes
              .map((RouteGenerator it) => it.fileInfoList)
              .expand((List<FileInfo> it) => it)
              .map((FileInfo it) => it.routes)
              .expand((List<RouteInfo> it) => it),
        );
      }
      routes.sort((RouteInfo a, RouteInfo b) =>
          a.ffRoute.name.compareTo(b.ffRoute.name));

      for (final RouteInfo it in routes) {
        if (it.ffRoute.argumentImports != null &&
            it.ffRoute.argumentImports.isNotEmpty) {
          for (final String element in it.ffRoute.argumentImports) {
            if (!imports.contains(element)) {
              imports.add(element);
            }
          }
        }
        caseSb.write(it.caseString);
      }

      writeImports(imports, sb);

      sb.write(rootFile.replaceAll('{0}', caseSb.toString()));
      RoutesFileGenerator(
        generateRouteConstants: generateRouteConstants,
        generateRouteNames: generateRouteNames,
        routesFileOutputPath: routesFileOutputPath,
        routes: routes,
        enableSupperArguments: enableSupperArguments,
        lib: _lib,
        packageNode: packageNode,
      ).generateRoutesFile();
    }
    var ss= sb.toString();
    if (sb.isNotEmpty) {
      file.createSync(recursive: true);
      file.writeAsStringSync(formatDart(fileHeader + sb.toString()));
      print('Generate : ${p.relative(file.path, from: packageNode.path)}');
    }
  }

  void generateHelperFile({
    List<RouteGenerator> nodes,
    bool routeSettingsNoArguments = false,
    bool generateRouteHelper = false,
    bool routeSettingsNoIsInitialRoute = false,
    String outputPath,
  }) {
    final List<String> parts = <String>[];
    parts.add(_lib.path);
    if (outputPath != null) {
      parts.add(outputPath);
    }
    parts.add('${packageNode.name}_route_helper.dart');
    final File file = File(p.joinAll(parts));
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (!generateRouteHelper) {
      return;
    }

    file.createSync(recursive: true);

    file.writeAsStringSync(formatDart('$fileHeader\n'
        '${routeHelper(
      packageNode.name,
      routeSettingsNoArguments,
      routeSettingsNoIsInitialRoute,
    )}\n'));
    print('Generate : ${p.relative(file.path, from: packageNode.path)}');
  }
}
