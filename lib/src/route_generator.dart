// // ignore_for_file: implementation_imports

// import 'dart:io';

// import 'package:analyzer/dart/analysis/analysis_context.dart';
// import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
// import 'package:analyzer/dart/analysis/features.dart';
// import 'package:analyzer/dart/analysis/results.dart';
// import 'package:analyzer/dart/analysis/session.dart';
// import 'package:analyzer/dart/analysis/utilities.dart';
// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/constant/value.dart';
// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/file_system/physical_file_system.dart';
// import 'package:build_runner_core/build_runner_core.dart';
// import 'package:collection/collection.dart' show IterableExtension;
// import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
// import 'package:path/path.dart' as p;
// import 'package:source_gen/source_gen.dart';

// import 'arg/args.dart';
// import 'file_info.dart';
// import 'route_info.dart';
// import 'routes_file_generator.dart';
// import 'template.dart';
// import 'utils/convert.dart';
// import 'utils/format.dart';
// import 'package:analyzer/src/dart/element/element.dart';

// TypeChecker fFRouteTypeChecker = const TypeChecker.fromRuntime(FFRoute);
// TypeChecker functionalWidgetTypeChecker = const TypeChecker.fromUrl(
//     'package:functional_widget_annotation/functional_widget_annotation.dart#FunctionalWidget');
// TypeChecker fFArgumentImportTypeChecker =
//     const TypeChecker.fromRuntime(FFArgumentImport);

// class RouteGenerator {
//   RouteGenerator(this.packageNode, this.isRoot);

//   final List<FileInfo> _fileInfoList = <FileInfo>[];

//   List<FileInfo> get fileInfoList => _fileInfoList;

//   Directory? _lib;

//   final PackageNode packageNode;
//   final bool isRoot;

//   bool get hasAnnotationRoute => _lib != null && _fileInfoList.isNotEmpty;

//   String get packageImport =>
//       "import 'package:${packageNode.name}/${packageNode.name}_route.dart';";

//   // get imports in root
//   String get imports {
//     if (_fileInfoList.isNotEmpty) {
//       final StringBuffer sb = StringBuffer();

//       _fileInfoList
//           .sort((FileInfo a, FileInfo b) => a.export!.compareTo(b.export!));
//       List<String> classNames = <String>[];
//       int pageCount = 0;
//       for (final FileInfo info in _fileInfoList) {
//         if (isRoot) {
//           classNames = <String>[];
//         }
//         String import = isRoot
//             ? "import '${info.export}'"
//             : packageImport.replaceRange(packageImport.length - 1, null, '');
//         for (final RouteInfo route in info.routes) {
//           if (route.classNameConflictPrefix != null) {
//             sb.write('$import as ${route.classNameConflictPrefix};\n');
//             classNames.add(route.className);
//           }
//           pageCount++;
//         }

//         if (isRoot) {
//           if (classNames.length != info.routes.length || classNames.isEmpty) {
//             if (classNames.isNotEmpty) {
//               import += ' hide ';
//               import += classNames.join(',');
//             }
//             sb.write('$import;\n');
//           }
//         }
//       }
//       if (!isRoot) {
//         String import =
//             packageImport.replaceRange(packageImport.length - 1, null, '');
//         if (classNames.length != pageCount || classNames.isEmpty) {
//           if (classNames.isNotEmpty) {
//             import += ' hide ';
//             import += classNames.join(',');
//           }
//           sb.write('$import;\n');
//         }
//       }
//       return sb.toString();
//     }
//     return '';
//   }

//   // for package
//   String get export {
//     if (_fileInfoList.isNotEmpty) {
//       assert(!isRoot);
//       final StringBuffer sb = StringBuffer();

//       sb.write('library ${packageNode.name}_route;\n');

//       _fileInfoList
//           .sort((FileInfo a, FileInfo b) => a.export!.compareTo(b.export!));

//       for (final FileInfo info in _fileInfoList) {
//         sb.write("export '${info.export}';\n");
//       }
//       return sb.toString();
//     }
//     return '';
//   }

//   Future<void> scanLib([String? output]) async {
//     if (_lib != null) {
//       print('');
//       print('Scanning package : ${packageNode.name}');

//       const TypeChecker typeChecker = TypeChecker.fromRuntime(FFRoute);
//       final String libPath = _lib!.path;

//       final AnalysisContextCollection collection1 = AnalysisContextCollection(
//           includedPaths: <String>[libPath],
//           resourceProvider: PhysicalResourceProvider.INSTANCE);

//       for (final AnalysisContext context in collection1.contexts) {
//         print('Analyzing ${context.contextRoot.root.path} ...');
//         for (final String filePath in context.contextRoot.analyzedFiles()) {
//           if (!filePath.endsWith('.dart')) {
//             continue;
//           }

//           final List<String> relativeParts = <String>[packageNode.path, 'lib'];
//           if (output != null) {
//             relativeParts.add(output);
//           }
//           final FileInfo fileInfo = FileInfo(
//             export: p
//                 .relative(filePath, from: p.joinAll(relativeParts))
//                 .replaceAll('\\', '/'),
//             packageName: packageNode.name,
//           );

//           final CompilationUnitElement fileElement =
//               await getElement(context.currentSession, filePath);

//           for (final ClassElement classElement in fileElement.classes) {
//             findFFRoute(fileInfo, classElement);
//           }

//           await _handleFunctionWidget(
//               fileElement, typeChecker, context, fileInfo);

//           if (fileInfo.routes.isNotEmpty) {
//             final FFRoute route = fileInfo.routes.first.ffRoute;
//             for (final LibraryImportElement importElement
//                 in fileElement.library.libraryImports) {
//               final DartObject? fFArgumentImportAnnotation =
//                   fFArgumentImportTypeChecker.firstAnnotationOf(importElement);

//               if (fFArgumentImportAnnotation != null) {
//                 final ConstantReader reader =
//                     ConstantReader(fFArgumentImportAnnotation);
//                 if (route.argumentImports != null) {
//                   final DirectiveUriWithLibraryImpl url =
//                       importElement.uri as DirectiveUriWithLibraryImpl;
//                   print(importElement.toString());
//                   String importString = '\'${url.relativeUriString}\'';
//                   String suffix = reader.peek('suffix')?.stringValue ?? '';
//                   for (final NamespaceCombinator combinator
//                       in importElement.combinators) {
//                     String combinatorString = combinator.toString();
//                     if (combinator is HideElementCombinatorImpl) {
//                       // bug
//                       combinatorString =
//                           combinatorString.replaceFirst('show', 'hide');
//                     }
//                     suffix += ' $combinatorString';
//                   }
//                   importString = 'import $importString $suffix ;';
//                   route.argumentImports!.add(importString);
//                 }
//               }
//             }

//             _fileInfoList.add(fileInfo);
//           }
//         }
//       }
//     }
//   }

//   Future<void> _handleFunctionWidget(
//       CompilationUnitElement fileElement,
//       TypeChecker typeChecker,
//       AnalysisContext context,
//       FileInfo fileInfo) async {
//     final Map<String, DartObject> _widgetFunctionMap = <String, DartObject>{};

//     for (final FunctionElement functionElement in fileElement.functions) {
//       final DartObject? annotation =
//           typeChecker.firstAnnotationOf(functionElement);
//       final DartObject? functionalWidget =
//           functionalWidgetTypeChecker.firstAnnotationOf(functionElement);
//       if (annotation != null && functionalWidget != null) {
//         _widgetFunctionMap[_funcName2ClassName(functionElement.name)] =
//             annotation;
//       }
//     }

//     if (_widgetFunctionMap.isNotEmpty) {
//       for (final PartElement partElement in fileElement.library.parts2) {
//         print(partElement.toString());
//         final DirectiveUri uri = partElement.uri;
//         String? path;
//         if (uri is DirectiveUriWithUnit) {
//           path = '${uri.unit.source.fullName}';
//         } else if (uri is DirectiveUriWithSource) {
//           path = '${uri.source.fullName}';
//         }
//         if (path != null) {
//           final CompilationUnitElement element =
//               await getElement(context.currentSession, path);
//           for (final ClassElement classElement in element.classes) {
//             if (_widgetFunctionMap.containsKey(classElement.name)) {
//               final DartObject? annotation =
//                   _widgetFunctionMap[classElement.name];
//               findFFRoute(fileInfo, classElement, annotation: annotation);
//             }
//           }
//         }
//       }
//     }
//   }

//   Future<CompilationUnitElement> getElement(
//       AnalysisSession analysisSession, String path) async {
//     return (await analysisSession.getUnitElement(path) as UnitElementResult)
//         .element;
//   }

//   void findFFRoute(FileInfo fileInfo, ClassElement classElement,
//       {DartObject? annotation}) {
//     annotation ??= fFRouteTypeChecker.firstAnnotationOf(classElement);
//     if (annotation != null) {
//       final ConstantReader reader = ConstantReader(annotation);

//       print(
//           'Found annotation route in ${classElement.source.uri} ------ class : ${classElement.displayName}');
//       // final ConstantReader? codes = reader.peek('codes');
//       // Map<String, String>? codesMap;
//       // if (codes != null) {
//       //   final ElementAnnotationImpl? elementAnnotation = classElement.metadata
//       //       .firstWhereOrNull((ElementAnnotation element) =>
//       //           (element as ElementAnnotationImpl).annotationAst.name.name ==
//       //           typeOf<FFRoute>().toString()) as ElementAnnotationImpl?;
//       //   final NodeList<Expression>? parameters =
//       //       elementAnnotation?.annotationAst.arguments?.arguments;

//       //   if (parameters != null) {
//       //     for (final Expression item in parameters) {
//       //       if (item is NamedExpressionImpl) {
//       //         String source;
//       //         source = item.expression.toSource();
//       //         if (source == 'null') {
//       //           continue;
//       //         }
//       //         final String key = item.name.toSource();
//       //         if (key == 'codes:') {
//       //           if (item.expression is SetOrMapLiteralImpl) {
//       //             final SetOrMapLiteralImpl setOrMapLiteralImpl =
//       //                 item.expression as SetOrMapLiteralImpl;
//       //             if (setOrMapLiteralImpl.elements.isNotEmpty) {
//       //               codesMap = <String, String>{};
//       //               for (final CollectionElement element
//       //                   in setOrMapLiteralImpl.elements) {
//       //                 final MapLiteralEntryImpl entry =
//       //                     element as MapLiteralEntryImpl;
//       //                 String value = entry.value.toString();

//       //                 value = value.replaceAll('\'', '');
//       //                 codesMap[entry.key.toString()] = value;
//       //               }
//       //             }
//       //           }
//       //           break;
//       //         }
//       //       }
//       //     }
//       //   }
//       // }
//       final RouteInfo routeInfo = RouteInfo(
//         className: classElement.displayName,
//         ffRoute: FFRoute(
//           name: reader.read('name').stringValue,
//           showStatusBar: reader.peek('showStatusBar')?.boolValue ?? true,
//           routeName: reader.peek('routeName')?.stringValue ?? '',
//           pageRouteType: PageRouteType.values.firstWhereOrNull(
//             (PageRouteType type) =>
//                 type.name ==
//                 reader.peek('pageRouteType')?.objectValue.variable?.displayName,
//           ),
//           description: reader.peek('description')?.stringValue ?? '',
//           exts: reader.peek('exts')?.mapValue.map<String, dynamic>(
//               (DartObject? key, DartObject? value) => MapEntry<String, dynamic>(
//                     _getValue(key),
//                     _getValue(value),
//                   )),
//           argumentImports: reader
//                   .peek('argumentImports')
//                   ?.listValue
//                   .map((DartObject e) => e.toStringValue()!)
//                   .toList() ??
//               <String>[],
//           //codes: codesMap,
//           codes: reader.peek('codes')?.mapValue.map<String, String>(
//               (DartObject? key, DartObject? value) => MapEntry<String, String>(
//                   _getValue(key), value!.toStringValue()!)),
//         ),
//         classElement: classElement,
//         node: this,
//       );
//       fileInfo.routes.add(routeInfo);
//     }
//   }

//   String _getValue(DartObject? object) {
//     if (object == null) {
//       return '';
//     }
//     final String valueString = object
//         .toString()
//         .replaceFirst(object.type!.getDisplayString(withNullability: false), '')
//         .trim();
//     // toString() = "${type.getDisplayString(withNullability: false)} ($_state)";

//     return valueString.substring(1, valueString.length - 1);
//   }

//   final Set<String> _functionalWidgetAnnotations = <String>{
//     'FunctionalWidget',
//     'swidget',
//     'hwidget',
//     'hcwidget',
//     'cwidget',
//   };

//   final Map<String, Iterable<ClassDeclaration>> _partClassDeclarations =
//       <String, Iterable<ClassDeclaration>>{};

//   ClassDeclaration? getFFRouteRefClassDeclaration(
//     Annotation metadata,
//     FileSystemEntity file,
//   ) {
//     if (metadata.name.name == typeOf<FFRoute>().toString()) {
//       final AstNode node = metadata.parent;
//       if (node is ClassDeclaration) {
//         return node;
//       } else if (node is FunctionDeclaration) {
//         final bool isFuncWidget = node.metadata.any((Annotation e) =>
//             _functionalWidgetAnnotations.contains(e.name.name));
//         if (isFuncWidget) {
//           final Iterable<PartDirective> parts = (node.parent as CompilationUnit)
//               .directives
//               .whereType<PartDirective>();
//           final String funcName = node.name2.toString();
//           final String className = _funcName2ClassName(funcName);
//           for (final PartDirective part in parts) {
//             final String join = p.join(file.parent.path, part.uri.stringValue!);
//             final String path = p.normalize(join);
//             final Iterable<ClassDeclaration> classes;
//             if (_partClassDeclarations.containsKey(path)) {
//               classes = _partClassDeclarations[path]!;
//             } else {
//               final CompilationUnit astRoot = parseFile(
//                 path: path,
//                 featureSet: FeatureSet.latestLanguageVersion(),
//               ).unit;
//               classes = astRoot.declarations.whereType<ClassDeclaration>();
//               _partClassDeclarations[path] = classes;
//             }
//             final ClassDeclaration? find = classes.firstWhereOrNull(
//                 (ClassDeclaration clazz) =>
//                     clazz.name2.toString() == className);
//             if (find != null) {
//               return find;
//             }
//           }
//           throw StateError(
//               '[$className] class not found, please run `flutter pub run build_runner build` before execute this.');
//         }
//       }
//     }
//     return null;
//   }

//   String _funcName2ClassName(String funcName) {
//     if (funcName.isNotEmpty && funcName[0] == '_') {
//       funcName = funcName.substring(1);
//     }
//     return funcName.replaceFirstMapped(RegExp('[a-zA-Z]'), (Match match) {
//       return match.group(0)!.toUpperCase();
//     });
//   }

//   void getLib() {
//     final Directory lib = Directory(p.join(packageNode.path, 'lib'));
//     if (lib.existsSync()) {
//       _lib = lib;
//     }
//   }

//   void generateFile({
//     List<RouteGenerator>? nodes,
//   }) {
//     final String name = '${packageNode.name}_route.dart';
//     String routePath;
//     if (isRoot && Args().outputPath != null) {
//       routePath = p.join(_lib!.path, Args().outputPath, name);
//     } else {
//       routePath = p.join(_lib!.path, name);
//     }

//     final File file = File(routePath);
//     if (file.existsSync()) {
//       file.deleteSync();
//     }
//     if (isRoot && _fileInfoList.isEmpty && (nodes?.isEmpty ?? true)) {
//       return;
//     }

//     final StringBuffer sb = StringBuffer();

//     final List<RouteInfo> routes = _fileInfoList
//         .map((FileInfo it) => it.routes)
//         .expand((List<RouteInfo> it) => it)
//         .toList();

//     if (nodes != null && nodes.isNotEmpty) {
//       routes.addAll(
//         nodes
//             .map((RouteGenerator it) => it.fileInfoList)
//             .expand((List<FileInfo> it) => it)
//             .map((FileInfo it) => it.routes)
//             .expand((List<RouteInfo> it) => it),
//       );
//     }
//     routes.sort(
//       (RouteInfo a, RouteInfo b) => a.ffRoute.name.compareTo(b.ffRoute.name),
//     );

//     final Map<String, List<RouteInfo>> conflictClassNames =
//         routes.groupListsBy((RouteInfo element) => element.className);

//     for (final String key in conflictClassNames.keys) {
//       final List<RouteInfo>? routes = conflictClassNames[key];
//       // ClassName is conflict
//       if (routes != null && routes.length > 1) {
//         for (final RouteInfo route in routes) {
//           route.classNameConflictPrefix =
//               route.className.toLowerCase() + route.ffRoute.name.md5;
//         }
//       }
//     }

//     if (isRoot) {
//       final Set<String> imports = <String>{};

//       final StringBuffer caseSb = StringBuffer();

//       /// Create route generator

//       imports.add('import \'package:flutter/widgets.dart\';');
//       imports.add(
//         'import \'package:ff_annotation_route_library/ff_annotation_route_library.dart\';',
//       );

//       /// Nodes import
//       ///
//       if (nodes != null && nodes.isNotEmpty) {
//         for (final RouteGenerator node in nodes) {
//           // add root imports
//           imports.addAll(node.imports.split('\n'));
//         }
//       }

//       // add root imports
//       imports.addAll(this.imports.split('\n'));

//       for (final RouteInfo it in routes) {
//         if (it.ffRoute.argumentImports != null &&
//             it.ffRoute.argumentImports!.isNotEmpty) {
//           imports.addAll(it.ffRoute.argumentImports!);
//         }
//         caseSb.write(it.caseString);
//       }
//       writeImports(imports, sb);

//       sb.write(rootFile
//           .replaceAll('{0}', caseSb.toString())
//           .replaceAll('{1}', Args().enableNullSafety ? 'required' : '@required')
//           .replaceAll('{2}', Args().enableNullSafety ? '?' : '')
//           .replaceAll(
//               '{3}',
//               Args().argumentsIsCaseSensitive
//                   ? '''  final Map<String, dynamic> safeArguments =
//       arguments ?? const <String, dynamic>{};'''
//                   : '''  Map<String, dynamic> safeArguments = arguments ?? const <String, dynamic>{};
//   if (arguments != null && arguments.isNotEmpty) {
//     final Map<String, dynamic> ignoreCaseMap = <String, dynamic>{};
//     safeArguments.forEach((String key, dynamic value) {
//       ignoreCaseMap[key.toLowerCase()] = value;
//     });
//     safeArguments = ignoreCaseMap;
//   }'''));
//     } else {
//       /// Export
//       sb.write(export);
//     }

//     // this is root project or this is package
//     if (isRoot || Args().isPackage) {
//       RoutesFileGenerator(
//         routes: routes,
//         lib: _lib,
//         packageNode: packageNode,
//       ).generateRoutesFile();
//     }

//     if (sb.isNotEmpty) {
//       file.createSync(recursive: true);
//       file.writeAsStringSync(formatDart(fileHeader + sb.toString()));
//       print('Generate : ${p.relative(file.path, from: packageNode.path)}');
//     }
//   }
// }
