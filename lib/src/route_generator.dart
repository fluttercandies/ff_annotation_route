import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:path/path.dart' as p;

import 'arg/args.dart';
import 'file_info.dart';
import 'route_info.dart';
import 'routes_file_generator.dart';
import 'template.dart';
import 'utils/convert.dart';
import 'utils/format.dart';

class RouteGenerator {
  RouteGenerator(this.packageNode, this.isRoot);

  final List<FileInfo> _fileInfoList = <FileInfo>[];

  List<FileInfo> get fileInfoList => _fileInfoList;

  Directory? _lib;

  final PackageNode packageNode;
  final bool isRoot;

  bool get hasAnnotationRoute => _lib != null && _fileInfoList.isNotEmpty;

  String get packageImport =>
      "import 'package:${packageNode.name}/${packageNode.name}_route.dart';";

  // get imports in root
  String get imports {
    if (_fileInfoList.isNotEmpty) {
      final StringBuffer sb = StringBuffer();

      _fileInfoList
          .sort((FileInfo a, FileInfo b) => a.export!.compareTo(b.export!));
      List<String> classNames = <String>[];
      int pageCount = 0;
      for (final FileInfo info in _fileInfoList) {
        if (isRoot) {
          classNames = <String>[];
        }
        String import = isRoot
            ? "import '${info.export}'"
            : packageImport.replaceRange(packageImport.length - 1, null, '');
        for (final RouteInfo route in info.routes) {
          if (route.classNameConflictPrefix != null) {
            sb.write('$import as ${route.classNameConflictPrefix};\n');
            classNames.add(route.className);
          }
          pageCount++;
        }

        if (isRoot) {
          if (classNames.length != info.routes.length || classNames.isEmpty) {
            if (classNames.isNotEmpty) {
              import += ' hide ';
              import += classNames.join(',');
            }
            sb.write('$import;\n');
          }
        }
      }
      if (!isRoot) {
        String import =
            packageImport.replaceRange(packageImport.length - 1, null, '');
        if (classNames.length != pageCount || classNames.isEmpty) {
          if (classNames.isNotEmpty) {
            import += ' hide ';
            import += classNames.join(',');
          }
          sb.write('$import;\n');
        }
      }
      return sb.toString();
    }
    return '';
  }

  // for package
  String get export {
    if (_fileInfoList.isNotEmpty) {
      assert(!isRoot);
      final StringBuffer sb = StringBuffer();

      sb.write('library ${packageNode.name}_route;\n');

      _fileInfoList
          .sort((FileInfo a, FileInfo b) => a.export!.compareTo(b.export!));

      for (final FileInfo info in _fileInfoList) {
        sb.write("export '${info.export}';\n");
      }
      return sb.toString();
    }
    return '';
  }

  void scanLib([String? output]) {
    if (_lib != null) {
      print('');
      print('Scanning package : ${packageNode.name}');
      final List<FileSystemEntity> files = _lib!.listSync(recursive: true);
      for (final FileSystemEntity item in files) {
        final FileStat file = item.statSync();
        if (file.type == FileSystemEntityType.file &&
            item.path.endsWith('.dart')) {
          final ParseStringResult result = parseFile(
            path: item.path,
            featureSet: FeatureSet.latestLanguageVersion(),
          );
          final CompilationUnit astRoot = result.unit;
          final List<String> argumentImports = <String>[];
          for (final SyntacticEntity child in astRoot.childEntities) {
            if (child is ImportDirective) {
              final SyntacticEntity? syntacticEntity = child.childEntities
                  .firstWhereOrNull(
                      (SyntacticEntity element) => element is Annotation);

              if (syntacticEntity != null) {
                final Annotation annotation = syntacticEntity as AnnotationImpl;
                if (annotation.name.name ==
                    typeOf<FFArgumentImport>().toString()) {
                  final NodeList<Expression>? parameters =
                      annotation.arguments?.arguments;
                  String import =
                      child.toString().replaceAll(annotation.toString(), '');
                  import = import.replaceAll(';', '');
                  if (parameters != null && parameters.isNotEmpty) {
                    import = import +
                        ' ' +
                        parameters.first.toString().replaceAll('\'', '');
                  }
                  import += ';\n';
                  argumentImports.add(import);
                }
              }
            }
          }

          FileInfo? fileInfo;
          for (final CompilationUnitMember declaration
              in astRoot.declarations) {
            for (final Annotation metadata in declaration.metadata) {
              final ClassDeclaration? ffRefClassDef =
                  getFFRouteRefClassDeclaration(metadata, item);
              if (ffRefClassDef != null) {
                final String className = ffRefClassDef.name2.toString();
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

                final NodeList<Expression>? parameters =
                    metadata.arguments?.arguments;
                if (parameters == null) {
                  continue;
                }
                String? name;
                bool? showStatusBar;
                String? routeName;
                PageRouteType? pageRouteType;
                String? description;
                Map<String, dynamic>? exts;
                Map<String, String>? codes;

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
                      case 'pageRouteType:':
                        pageRouteType = PageRouteType.values.firstWhereOrNull(
                          (PageRouteType type) => type.toString() == source,
                        );
                        break;
                      case 'description:':
                        description = toT<String>(item.expression);
                        break;
                      case 'argumentImports:':
                        argumentImports
                            .addAll(toT<List<String>>(item.expression)!);
                        break;
                      case 'exts:':
                      case 'codes:':
                        if (item.expression is SetOrMapLiteralImpl) {
                          final SetOrMapLiteralImpl setOrMapLiteralImpl =
                              item.expression as SetOrMapLiteralImpl;
                          final bool isCodes = key == 'codes:';
                          if (setOrMapLiteralImpl.elements.isNotEmpty) {
                            final Map<String, dynamic> map = isCodes
                                ? codes ??= <String, String>{}
                                : exts ??= <String, dynamic>{};
                            for (final CollectionElement element
                                in setOrMapLiteralImpl.elements) {
                              final MapLiteralEntryImpl entry =
                                  element as MapLiteralEntryImpl;
                              String value = entry.value.toString();
                              if (isCodes) {
                                value = value.replaceAll('\'', '');
                              }
                              map[entry.key.toString()] = value;
                            }
                          }
                        }
                    }
                  }
                }

                final RouteInfo routeInfo = RouteInfo(
                  className: className,
                  ffRoute: FFRoute(
                    name: name!,
                    showStatusBar: showStatusBar ?? true,
                    routeName: routeName ?? '',
                    pageRouteType: pageRouteType,
                    description: description ?? '',
                    exts: exts,
                    argumentImports: argumentImports,
                    codes: codes,
                  ),
                  constructors: ffRefClassDef.members
                      .whereType<ConstructorDeclaration>()
                      .toList(),
                  fields: ffRefClassDef.members
                      .whereType<FieldDeclaration>()
                      .toList(),
                  routePath: routePath,
                  classDeclaration: ffRefClassDef,
                  node: this,
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

  final Set<String> _functionalWidgetAnnotations = <String>{
    'FunctionalWidget',
    'swidget',
    'hwidget',
    'hcwidget',
    'cwidget',
  };

  final Map<String, Iterable<ClassDeclaration>> _partClassDeclarations =
      <String, Iterable<ClassDeclaration>>{};

  ClassDeclaration? getFFRouteRefClassDeclaration(
    Annotation metadata,
    FileSystemEntity file,
  ) {
    if (metadata.name.name == typeOf<FFRoute>().toString()) {
      final AstNode node = metadata.parent;
      if (node is ClassDeclaration) {
        return node;
      } else if (node is FunctionDeclaration) {
        final bool isFuncWidget = node.metadata.any((Annotation e) =>
            _functionalWidgetAnnotations.contains(e.name.name));
        if (isFuncWidget) {
          final Iterable<PartDirective> parts = (node.parent as CompilationUnit)
              .directives
              .whereType<PartDirective>();
          final String funcName = node.name2.toString();
          final String className = _funcName2ClassName(funcName);
          for (final PartDirective part in parts) {
            final String join = p.join(file.parent.path, part.uri.stringValue!);
            final String path = p.normalize(join);
            final Iterable<ClassDeclaration> classes;
            if (_partClassDeclarations.containsKey(path)) {
              classes = _partClassDeclarations[path]!;
            } else {
              final CompilationUnit astRoot = parseFile(
                path: path,
                featureSet: FeatureSet.latestLanguageVersion(),
              ).unit;
              classes = astRoot.declarations.whereType<ClassDeclaration>();
              _partClassDeclarations[path] = classes;
            }
            final ClassDeclaration? find = classes.firstWhereOrNull(
                (ClassDeclaration clazz) =>
                    clazz.name2.toString() == className);
            if (find != null) {
              return find;
            }
          }
          throw StateError(
              '[$className] class not found, please run `flutter pub run build_runner build` before execute this.');
        }
      }
    }
    return null;
  }

  String _funcName2ClassName(String funcName) {
    if (funcName.isNotEmpty && funcName[0] == '_') {
      funcName = funcName.substring(1);
    }
    return funcName.replaceFirstMapped(RegExp('[a-zA-Z]'), (Match match) {
      return match.group(0)!.toUpperCase();
    });
  }

  void getLib() {
    final Directory lib = Directory(p.join(packageNode.path, 'lib'));
    if (lib.existsSync()) {
      _lib = lib;
    }
  }

  void generateFile({
    List<RouteGenerator>? nodes,
  }) {
    final String name = '${packageNode.name}_route.dart';
    String routePath;
    if (isRoot && Args().outputPath != null) {
      routePath = p.join(_lib!.path, Args().outputPath, name);
    } else {
      routePath = p.join(_lib!.path, name);
    }

    final File file = File(routePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (isRoot && _fileInfoList.isEmpty && (nodes?.isEmpty ?? true)) {
      return;
    }

    final StringBuffer sb = StringBuffer();

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
    routes.sort(
      (RouteInfo a, RouteInfo b) => a.ffRoute.name.compareTo(b.ffRoute.name),
    );

    final Map<String, List<RouteInfo>> conflictClassNames =
        routes.groupListsBy((RouteInfo element) => element.className);

    for (final String key in conflictClassNames.keys) {
      final List<RouteInfo>? routes = conflictClassNames[key];
      // ClassName is conflict
      if (routes != null && routes.length > 1) {
        for (final RouteInfo route in routes) {
          route.classNameConflictPrefix =
              route.className.toLowerCase() + route.ffRoute.name.md5;
        }
      }
    }

    if (isRoot) {
      final Set<String> imports = <String>{};

      final StringBuffer caseSb = StringBuffer();

      /// Create route generator

      imports.add('import \'package:flutter/widgets.dart\';');
      imports.add(
        'import \'package:ff_annotation_route_library/ff_annotation_route_library.dart\';',
      );

      /// Nodes import
      ///
      if (nodes != null && nodes.isNotEmpty) {
        for (final RouteGenerator node in nodes) {
          // add root imports
          imports.addAll(node.imports.split('\n'));
        }
      }

      // add root imports
      imports.addAll(this.imports.split('\n'));

      for (final RouteInfo it in routes) {
        if (it.ffRoute.argumentImports != null &&
            it.ffRoute.argumentImports!.isNotEmpty) {
          imports.addAll(it.ffRoute.argumentImports!);
        }
        caseSb.write(it.caseString);
      }
      writeImports(imports, sb);

      sb.write(rootFile
          .replaceAll('{0}', caseSb.toString())
          .replaceAll('{1}', Args().enableNullSafety ? 'required' : '@required')
          .replaceAll('{2}', Args().enableNullSafety ? '?' : '')
          .replaceAll(
              '{3}',
              Args().argumentsIsCaseSensitive
                  ? '''  final Map<String, dynamic> safeArguments =
      arguments ?? const <String, dynamic>{};'''
                  : '''  Map<String, dynamic> safeArguments = arguments ?? const <String, dynamic>{};
  if (arguments != null && arguments.isNotEmpty) {
    final Map<String, dynamic> ignoreCaseMap = <String, dynamic>{};
    safeArguments.forEach((String key, dynamic value) {
      ignoreCaseMap[key.toLowerCase()] = value;
    });
    safeArguments = ignoreCaseMap;
  }'''));
    } else {
      /// Export
      sb.write(export);
    }

    // this is root project or this is package
    if (isRoot || Args().isPackage) {
      RoutesFileGenerator(
        routes: routes,
        lib: _lib,
        packageNode: packageNode,
      ).generateRoutesFile();
    }

    if (sb.isNotEmpty) {
      file.createSync(recursive: true);
      file.writeAsStringSync(formatDart(fileHeader + sb.toString()));
      print('Generate : ${p.relative(file.path, from: packageNode.path)}');
    }
  }
}
