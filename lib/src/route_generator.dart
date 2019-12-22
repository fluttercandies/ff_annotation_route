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
                    final key = item.name.toSource();
                    if (key == "name:") {
                      name = item.expression.toSource();
                    } else if (key == "argumentNames:") {
                      final list = json.decode(
                        item.expression.toSource(),
                      ) as List;
                      argumentNames = list.map((f) => f.toString()).toList();
                    } else if (key == "showStatusBar:") {
                      showStatusBar = item.expression.toSource() == "true";
                    } else if (key == "routeName:") {
                      routeName = item.expression.toSource();
                    } else if (key == "pageRouteType:") {
                      pageRouteType = PageRouteType.values.firstWhere(
                        (type) => type.toString() == item.expression.toSource(),
                        orElse: () => null,
                      );
                    } else if (key == "description:") {
                      description = item.expression.toSource();
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
      _fileInfoList.forEach((info) {
        info.routes.forEach((route) {
          routeNames.add(route.ffRoute.name.replaceAll('\"', ''));
          caseSb.write(route.caseString);
        });
      });

      if (nodes != null && nodes.isNotEmpty) {
        nodes.forEach((node) {
          node.fileInfoList.forEach((info) {
            info.routes.forEach((route) {
              routeNames.add(route.ffRoute.name.replaceAll('\"', ''));
              caseSb.write(route.caseString);
            });
          });
        });
      }

      sb.write(rootFile.replaceAll('{0}', caseSb.toString()));

      if (generateRouteNames) {
        sb.write('\n');
        sb.write('List<String> routeNames = ${json.encode(routeNames)};');
      }

      if (generateRouteConstants) {
        sb.write('class Routes {\n');

        _fileInfoList.forEach((info) {
          info.routes.forEach((route) {
            final _route = route.ffRoute;

            final _name = _route.name.replaceAll('\"', '');
            final _routeName = _route.routeName.replaceAll('\"', '');
            final _description = _route.description;
            final _arguments = _route.argumentNames;
            final _showStatusBar = _route.showStatusBar;
            final _pageRouteType = _route.pageRouteType;

            final _firstLine = _description ?? _routeName ?? _name;

            final _constant = _name
                .replaceAll('\"', '')
                .replaceAll('://', '_')
                .replaceAll('/', '_')
                .replaceAll('.', '_')
                .replaceAll(' ', '_')
                .replaceAll('-', '_');

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
          });
        });

        sb.write('}');
      }
    }

    if (sb.isNotEmpty) {
      file.createSync();
      file.writeAsStringSync(fileHeader +
          '\n' +
          (isRoot ? "import 'package:flutter/widgets.dart';\n\n" : '') +
          sb.toString());
      print('Generate : ${p.relative(file.path, from: packageNode.path)}');
    }

    return file;
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
        '$fileHeader\n$routeHelper\n${routeSettingsNoArguments ? ffRouteSettingsNoArguments : ffRouteSettings}');
    print('Generate : ${p.relative(file.path, from: packageNode.path)}');

    return file;
  }
}
