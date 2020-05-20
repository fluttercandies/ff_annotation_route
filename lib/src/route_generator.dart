import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';

// ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:ff_annotation_route/src/utils/ast.dart';
import 'package:path/path.dart' as p;

import 'ff_route.dart';
import 'file_info.dart';
import 'package_graph.dart';
import 'route_info.dart';
import 'utils.dart';
import 'utils/camel_under_score_converter.dart';
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
          final CompilationUnit astRoot = parseDartFile(item.path);

          FileInfo fileInfo;
          for (final CompilationUnitMember declaration
              in astRoot.declarations) {
            for (final Annotation metadata in declaration.metadata) {
              if (metadata is AnnotationImpl &&
                  metadata.name?.name == typeOf<FFRoute>().toString() &&
                  metadata.parent is ClassDeclarationImpl) {
                final String className =
                    (metadata.parent as ClassDeclarationImpl).name?.name;

                print(
                    'Found annotation route : ${p.relative(item.path, from: packageNode.path)} ------ class : $className');

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
                List<String> argumentNames;
                bool showStatusBar;
                String routeName;
                PageRouteType pageRouteType;
                String description;
                Map<String, dynamic> exts;

                for (final Expression item in parameters) {
                  if (item is NamedExpressionImpl) {
                    String source;
                    source = item.expression.toSource();
                    if (source == 'null') {
                      continue;
                    }
                    // using single quotes has greater possibility.
                    if (source.length >= 2 &&
                        source.startsWith("'") &&
                        source.endsWith("'")) {
                      source = '"${source.substring(1, source.length - 1)}"';
                    } else if (source.startsWith("'''") &&
                        source.endsWith("'''")) {
                      source = '"${source.substring(3, source.length - 3)}"';
                    }
                    final String key = item.name.toSource();
                    switch (key) {
                      case 'name:':
                        name = source;
                        break;
                      case 'routeName:':
                        routeName = source;
                        break;
                      case 'showStatusBar:':
                        showStatusBar = source == 'true';
                        break;
                      case 'argumentNames:':
                        source = source.substring(source.indexOf('['));
                        argumentNames = source
                            .replaceAll(RegExp('\\[|\\]'), '')
                            .split(',')
                            .map((String it) => it.trim())
                            .where((String it) => it.length > 2)
                            .map((String it) =>
                                it.startsWith("'''") && it.endsWith("'''")
                                    ? it.substring(3, it.length - 3)
                                    : it.substring(1, it.length - 1))
                            .toList();
                        break;
                      case 'pageRouteType:':
                        pageRouteType = PageRouteType.values.firstWhere(
                          (PageRouteType type) => type.toString() == source,
                          orElse: () => null,
                        );
                        break;
                      case 'description:':
                        description = source;
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
                    argumentNames: argumentNames,
                    showStatusBar: showStatusBar,
                    routeName: routeName,
                    pageRouteType: pageRouteType,
                    description: description,
                    exts: exts,
                  ),
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
    file.createSync(recursive: true);
    if (isRoot && _fileInfoList.isEmpty && (nodes?.isEmpty ?? true)) {
      return;
    }

    final StringBuffer sb = StringBuffer();

    /// Nodes import
    if (isRoot && nodes != null && nodes.isNotEmpty) {
      for (final RouteGenerator node in nodes) {
        sb.write('${node.import}\n');
      }
    }

    /// Export
    sb.write(export);

    /// Create route generator
    if (isRoot) {
      final StringBuffer caseSb = StringBuffer();
      final List<String> routeNames = <String>[];
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
        routeNames.add(it.ffRoute.name.replaceAll('\"', ''));
        caseSb.write(it.caseString.replaceAll('"', '\''));
      }

      sb.write(rootFile.replaceAll('{0}', caseSb.toString()));

      _generateRoutesFile(generateRouteConstants, routesFileOutputPath,
          generateRouteNames, routeNames, routes);
    }

    if (sb.isNotEmpty) {
      file.createSync();
      file.writeAsStringSync(formatter.format(fileHeader +
          '\n' +
          (isRoot ? 'import \'package:flutter/widgets.dart\';\n\n' : '') +
          sb.toString()));
      print('Generate : ${p.relative(file.path, from: packageNode.path)}');
    }
  }

  void _generateRoutesFile(
      bool generateRouteConstants,
      String routesFileOutputPath,
      bool generateRouteNames,
      List<String> routeNames,
      List<RouteInfo> routes) {
    if (generateRouteConstants || generateRouteNames) {
      final StringBuffer constantsSb = StringBuffer();
      final String name = '${packageNode.name}_routes.dart';
      String routePath;

      if (routesFileOutputPath != null) {
        routePath = p.join(_lib.path, routesFileOutputPath, name);
      } else {
        routePath = p.join(_lib.path, name);
      }

      final File file = File(routePath);
      if (file.existsSync()) {
        file.deleteSync();
      }

      if (generateRouteNames) {
        constantsSb.write(fileHeader);
        constantsSb.write(
            'const List<String> routeNames = <String>${json.encode(routeNames).replaceAll('"', '\'')};');
        constantsSb.write('\n');
      }

      if (generateRouteConstants) {
        if (constantsSb.isEmpty) {
          constantsSb.write(fileHeader);
        }
        constantsSb.write('class Routes {\n');
        constantsSb.write('const Routes._();\n');
        for (final RouteInfo it in routes) {
          _generateRouteConstant(it, constantsSb);
        }
        constantsSb.write('}');
      }
      if (constantsSb.isNotEmpty) {
        file.createSync(recursive: true);
        file.writeAsStringSync(formatter.format(constantsSb.toString()));
        print('Generate : ${p.relative(file.path, from: packageNode.path)}');
      }
    }
  }

  void _generateRouteConstant(RouteInfo route, StringBuffer sb) {
    final FFRoute _route = route.ffRoute;

    final String _name = _route.name.replaceAll('\"', '');
    final String _routeName = _route.routeName.replaceAll('\"', '');
    final String _description = _route.description;
    final List<String> _arguments = _route.argumentNames;
    final bool _showStatusBar = _route.showStatusBar;
    final PageRouteType _pageRouteType = _route.pageRouteType;
    final Map<String, dynamic> _exts = _route.exts;

    final String _firstLine = _description ?? _routeName ?? _name;

    String _constant;
    _constant = camelName(_name)
        .replaceAll('\"', '')
        .replaceAll('://', '_')
        .replaceAll('/', '_')
        .replaceAll('.', '_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    while (_constant.startsWith('_')) {
      _constant = _constant.replaceFirst('_', '');
    }

    sb.write('/// $_firstLine\n');
    sb.write('///');
    sb.write('\n/// [name] : $_name');
    if (_routeName != null) {
      sb.write('\n///');
      sb.write('\n/// [routeName] : $_routeName');
    }
    if (_description != null) {
      sb.write('\n///');
      sb.write('\n/// [description] : $_description');
    }
    if (_arguments != null) {
      sb.write('\n///');
      sb.write('\n/// [arguments] : $_arguments');
    }
    if (_showStatusBar != null) {
      sb.write('\n///');
      sb.write('\n/// [showStatusBar] : $_showStatusBar');
    }
    if (_pageRouteType != null) {
      sb.write('\n///');
      sb.write('\n/// [pageRouteType] : $_pageRouteType');
    }

    if (_exts != null) {
      sb.write('\n///');
      sb.write('\n/// [exts] : $_exts');
    }

    sb.write(
      '\nstatic const String '
      '${camelName(_constant)} = \'$_name\';\n\n',
    );
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

    file.writeAsStringSync(formatter.format('$fileHeader\n'
        '${routeHelper(
      packageNode.name,
      routeSettingsNoArguments,
      routeSettingsNoIsInitialRoute,
    )}\n'));
    print('Generate : ${p.relative(file.path, from: packageNode.path)}');
  }
}
