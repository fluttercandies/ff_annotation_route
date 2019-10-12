import 'dart:io';
import 'route_info.dart';
import 'utils.dart';
import 'package:path/path.dart' as p;
import 'ast.dart';
import 'file_info.dart';
import 'ff_route.dart';
import 'package_graph.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'dart:convert';

class RouteGenerator {
  List<FileInfo> _fileInfos = List<FileInfo>();
  List<FileInfo> get fileInfos => _fileInfos;
  bool get isRoot => packageNode.isRoot;
  Directory _lib;

  final PackageNode packageNode;
  bool get hasAnnotationRoute => _lib != null && _fileInfos.isNotEmpty;

  String get import =>
      "import 'package:${packageNode.name}/${packageNode.name}_route.dart';";

  String get export {
    if (_fileInfos.isNotEmpty) {
      StringBuffer sb = StringBuffer();

      if (!isRoot) {
        sb.write("library ${packageNode.name}_route;\n");
      }

      _fileInfos.forEach((info) {
        sb.write("${isRoot ? "import" : "export"} '${info.export}'; \n");
      });
      return sb.toString();
    }
    return "";
  }

  RouteGenerator(this.packageNode);

  void scanLib() {
    if (_lib != null) {
      print("");
      print("scan package : ${packageNode.name}");
      for (var item in _lib.listSync(recursive: true)) {
        var file = item.statSync();
        if (file.type == FileSystemEntityType.file &&
            item.path.endsWith(".dart")) {
          CompilationUnitImpl astRoot = parseDartFile(item.path);

          FileInfo fileInfo;
          for (var declaration in astRoot.declarations) {
            for (var metadata in declaration.metadata) {
              if (metadata is AnnotationImpl &&
                  metadata.name?.name == typeOf<FFRoute>().toString() &&
                  metadata.parent is ClassDeclarationImpl) {
                var className =
                    (metadata.parent as ClassDeclarationImpl).name?.name;

                print(
                    "find annotation route : ${p.relative(item.path, from: packageNode.path)} ------- class : $className");

                fileInfo ??= FileInfo(
                    export: p
                        .relative(item.path,
                            from: p.join(packageNode.path, "lib"))
                        .replaceAll("\\", "/"),
                    packageName: packageNode.name);

                var parameters = metadata.arguments?.arguments;

                String name = "";

                List<String> argumentNames;

                bool showStatusBar;

                String routeName;

                PageRouteType pageRouteType;

                String description;

                for (var item in parameters) {
                  if (item is NamedExpressionImpl) {
                    var key = item.name.toSource();
                    if (key == "name:") {
                      name = item.expression.toSource();
                    } else if (key == "argumentNames:") {
                      var list =
                          json.decode(item.expression.toSource()) as List;
                      argumentNames = list.map((f) => f.toString()).toList();
                    } else if (key == "showStatusBar:") {
                      showStatusBar = item.expression.toSource() == "true";
                    } else if (key == "routeName:") {
                      routeName = item.expression.toSource();
                    } else if (key == "pageRouteType:") {
                      pageRouteType = PageRouteType.values.firstWhere(
                          (type) =>
                              type.toString() == item.expression.toSource(),
                          orElse: () => null);
                    } else if (key == "description:") {
                      description = item.expression.toSource();
                    }
                  }
                }
                RouteInfo routeInfo = RouteInfo(
                    className: className,
                    ffRoute: FFRoute(
                        name: name,
                        argumentNames: argumentNames,
                        showStatusBar: showStatusBar,
                        routeName: routeName,
                        pageRouteType: pageRouteType,
                        description: description));

                fileInfo.routes.add(routeInfo);
              }
            }
          }
          if (fileInfo != null) {
            _fileInfos.add(fileInfo);
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
  }) {
    File file = File(p.join(_lib.path, "${packageNode.name}_route.dart"));
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (isRoot && _fileInfos.isEmpty && (nodes?.isEmpty ?? true)) {
      return;
    }

    StringBuffer sb = StringBuffer();

    //nodes import
    if (packageNode.isRoot && nodes != null && nodes.isNotEmpty) {
      nodes.forEach((node) {
        sb.write(node.import + "\n");
      });
    }
    //export
    sb.write(export);

    //create route generator
    if (isRoot) {
      StringBuffer caseSb = StringBuffer();
      List<String> routeNames = List<String>();
      _fileInfos.forEach((info) {
        info.routes.forEach((route) {
          routeNames.add(route.ffRoute.name.replaceAll("\"", ""));
          caseSb.write(route.caseString);
        });
      });

      if (nodes != null && nodes.isNotEmpty) {
        nodes.forEach((node) {
          node.fileInfos.forEach((info) {
            info.routes.forEach((route) {
              routeNames.add(route.ffRoute.name.replaceAll("\"", ""));
              caseSb.write(route.caseString);
            });
          });
        });
      }

      sb.write(rootFile.replaceAll("{0}", caseSb.toString()));

      if (generateRouteNames) {
        sb.write("\n");
        sb.write("List<String> routeNames = ${json.encode(routeNames)};");
      }
    }

    if (sb.isNotEmpty) {
      file.createSync();
      file.writeAsStringSync(fileHeader +
          "\n" +
          (isRoot ? "import 'package:flutter/widgets.dart';\n" : "") +
          sb.toString());
      print("generate : ${p.relative(file.path, from: packageNode.path)}");
    }
  }

  void generateHelperFile(
      {List<RouteGenerator> nodes,
      bool routeSettingsNoArguments = false,
      int mode = 0}) {
    File file =
        File(p.join(_lib.path, "${packageNode.name}_route_helper.dart"));
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (mode == 0) return;

    file.createSync();

    file.writeAsStringSync(
        "$fileHeader\nimport ${packageNode.name}_route.dart\n$routeHelper\n${routeSettingsNoArguments ? ffRouteSettingsNoArguments : ffRouteSettings}");
    print("generate : ${p.relative(file.path, from: packageNode.path)}");
  }
}
