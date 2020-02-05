import 'dart:convert';
import 'dart:io';

import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'ast.dart';
import 'ff_route.dart';
import 'file_info.dart';
import 'package_graph.dart';
import 'route_info.dart';
import 'utils.dart';

class RouteGenerator {
  final _fileInfoList = <FileInfo>[];

  List<FileInfo> get fileInfoList => _fileInfoList;

  bool get isRoot => packageNode.isRoot;
  Directory _lib;

  final PackageNode packageNode;

  bool get hasAnnotationRoute => _lib != null && _fileInfoList.isNotEmpty;

  String get import =>
      "import 'package:${packageNode.name}/${packageNode.name}_route.dart';";

  String get export {
    if (_fileInfoList.isNotEmpty) {
      final sb = StringBuffer();

      if (!isRoot) {
        sb.write('library ${packageNode.name}_route;\n');
      }

      _fileInfoList.forEach((info) {
        sb.write("${isRoot ? "import" : "export"} '${info.export}'; \n");
      });
      return sb.toString();
    }
    return '';
  }

  RouteGenerator(this.packageNode);

  void scanLib() {
    if (_lib != null) {
      print('');
      print('Scanning package : ${packageNode.name}');
      for (final item in _lib.listSync(recursive: true)) {
        final file = item.statSync();
        if (file.type == FileSystemEntityType.file &&
            item.path.endsWith('.dart')) {
          CompilationUnitImpl astRoot = parseDartFile(item.path);

          FileInfo fileInfo;
          for (final declaration in astRoot.declarations) {
            for (final metadata in declaration.metadata) {
              if (metadata is AnnotationImpl &&
                  metadata.name?.name == typeOf<FFRoute>().toString() &&
                  metadata.parent is ClassDeclarationImpl) {
                final className =
                    (metadata.parent as ClassDeclarationImpl).name?.name;

                print(
                    'Found annotation route : ${p.relative(item.path, from: packageNode.path)} ------ class : $className');

                fileInfo ??= FileInfo(
                    export: p
                        .relative(item.path,
                            from: p.join(packageNode.path, 'lib'))
                        .replaceAll('\\', '/'),
                    packageName: packageNode.name);

                final parameters = metadata.arguments?.arguments;

                String name;
                List<String> argumentNames;
                bool showStatusBar;
                String routeName;
                PageRouteType pageRouteType;
                String description;

                for (final item in parameters) {
                  if (item is NamedExpressionImpl) {
                    var source = item.expression.toSource();
                    if (source == 'null') continue;
                    // using single quotes has greater possibility.
                    if (source.length >= 2 &&
                        source.startsWith("'") &&
                        source.endsWith("'")) {
                      source = '"${source.substring(1, source.length - 1)}"';
                    } else if (source.startsWith("'''") &&
                        source.endsWith("'''")) {
                      source = '"${source.substring(3, source.length - 3)}"';
                    }
                    final key = item.name.toSource();
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
                        argumentNames = source
                            .replaceAll(RegExp('\\[|\\]'), '')
                            .split(',')
                            .map((it) => it.trim())
                            .where((it) => it.length > 2)
                            .map((it) =>
                        it.startsWith("'''") && it.endsWith("'''")
                            ? it.substring(3, it.length - 3)
                            : it.substring(1, it.length - 1))
                            .toList();
                        break;
                      case 'pageRouteType:':
                        pageRouteType = PageRouteType.values.firstWhere(
                              (type) => type.toString() == source,
                          orElse: () => null,
                        );
                        break;
                      case 'description:':
                        description = source;
                        break;
                    }
                  }
                }

                final routeInfo = RouteInfo(
                  className: className,
                  ffRoute: FFRoute(
                    name: name,
                    argumentNames: argumentNames,
                    showStatusBar: showStatusBar,
                    routeName: routeName,
                    pageRouteType: pageRouteType,
                    description: description,
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
    final lib = Directory(p.join(packageNode.path, 'lib'));
    if (lib.existsSync()) _lib = lib;
  }

  File generateFile({
    List<RouteGenerator> nodes,
    bool generateRouteNames = false,
    bool generateRouteConstants = false,
  }) {
    final file = File(p.join(_lib.path, '${packageNode.name}_route.dart'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (isRoot && _fileInfoList.isEmpty && (nodes?.isEmpty ?? true)) {
      return null;
    }

    final sb = StringBuffer();

    /// Nodes import
    if (packageNode.isRoot && nodes != null && nodes.isNotEmpty) {
      nodes.forEach((node) {
        sb.write('${node.import}\n');
      });
    }

    /// Export
    sb.write(export);

    /// Create route generator
    if (isRoot) {
      final caseSb = StringBuffer();
      final routeNames = <String>[];
      final routes =
          _fileInfoList.map((it) => it.routes).expand((it) => it).toList();
      if (nodes != null && nodes.isNotEmpty) {
        routes.addAll(
          nodes
              .map((it) => it.fileInfoList)
              .expand((it) => it)
              .map((it) => it.routes)
              .expand((it) => it),
        );
      }
      routes.sort((a, b) => a.ffRoute.name.compareTo(b.ffRoute.name));

      routes.forEach((it) {
        routeNames.add(it.ffRoute.name.replaceAll('\"', ''));
        caseSb.write(it.caseString);
      });

      sb.write(rootFile.replaceAll('{0}', caseSb.toString()));

      if (generateRouteNames) {
        sb.write('\n');
        sb.write('List<String> routeNames = ${json.encode(routeNames)};');
        sb.write('\n');
      }

      if (generateRouteConstants) {
        sb.write('class Routes {\n');
        sb.write('const Routes._();\n');
        routes.forEach((it) {
          _generateRouteConstant(it, sb);
        });
        sb.write('}');
      }
    }

    if (sb.isNotEmpty) {
      file.createSync();
      file.writeAsStringSync(fileHeader +
          '\n' +
          (isRoot ? 'import \'package:flutter/widgets.dart\';\n\n' : '') +
          sb.toString());
      print('Generate : ${p.relative(file.path, from: packageNode.path)}');
    }

    return file;
  }

  void _generateRouteConstant(RouteInfo route, StringBuffer sb) {
    final _route = route.ffRoute;

    final _name = _route.name.replaceAll('\"', '');
    final _routeName = _route.routeName.replaceAll('\"', '');
    final _description = _route.description;
    final _arguments = _route.argumentNames;
    final _showStatusBar = _route.showStatusBar;
    final _pageRouteType = _route.pageRouteType;

    final _firstLine = _description ?? _routeName ?? _name;

    var _constant = _name
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
      sb.write('\n/// [routeName] : $_routeName');
    }
    if (_description != null) {
      sb.write('\n/// [description] : $_description');
    }
    if (_arguments != null) {
      sb.write('\n/// [arguments] : $_arguments');
    }
    if (_showStatusBar != null) {
      sb.write('\n/// [showStatusBar] : $_showStatusBar');
    }
    if (_pageRouteType != null) {
      sb.write('\n/// [pageRouteType] : $_pageRouteType');
    }
    sb.write(
      '\nstatic const String '
      '${_constant.toUpperCase()} = \"$_name\";\n\n',
    );
  }

  File generateHelperFile({
    List<RouteGenerator> nodes,
    bool routeSettingsNoArguments = false,
    int mode = 0,
  }) {
    final file =
        File(p.join(_lib.path, '${packageNode.name}_route_helper.dart'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (mode == 0) return null;

    file.createSync();

    file.writeAsStringSync(
      '$fileHeader\n'
      '${routeHelper(packageNode.name)}\n'
      '${routeSettingsNoArguments ? ffRouteSettingsNoArguments : ffRouteSettings}',
    );
    print('Generate : ${p.relative(file.path, from: packageNode.path)}');

    return file;
  }
}
