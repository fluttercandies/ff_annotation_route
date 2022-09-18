// ignore_for_file: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route/src/file_info.dart';
import 'package:ff_annotation_route/src/route_info/route_info.dart';
import 'package:ff_annotation_route/src/template.dart';
import 'package:ff_annotation_route/src/utils/dart_type_auto_import.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/constant/value.dart';
import 'route_generator_base.dart';

TypeChecker fFRouteTypeChecker = const TypeChecker.fromRuntime(FFRoute);
TypeChecker functionalWidgetTypeChecker = const TypeChecker.fromUrl(
    'package:functional_widget_annotation/functional_widget_annotation.dart#FunctionalWidget');
TypeChecker fFArgumentImportTypeChecker =
    const TypeChecker.fromRuntime(FFArgumentImport);

class RouteGenerator extends RouteGeneratorBase {
  RouteGenerator(PackageNode packageNode, bool isRoot)
      : super(packageNode, isRoot);

  @override
  Future<void> scanLib([String? output]) async {
    if (lib != null) {
      print('');
      print('Scanning package : ${packageNode.name}');

      const TypeChecker typeChecker = TypeChecker.fromRuntime(FFRoute);
      final String libPath = lib!.path;

      final AnalysisContextCollection collection1 = AnalysisContextCollection(
          includedPaths: <String>[libPath],
          resourceProvider: PhysicalResourceProvider.INSTANCE);

      for (final AnalysisContext context in collection1.contexts) {
        print('Analyzing ${context.contextRoot.root.path} ...');
        for (final String filePath in context.contextRoot.analyzedFiles()) {
          if (!filePath.endsWith('.dart')) {
            continue;
          }

          final List<String> relativeParts = <String>[packageNode.path, 'lib'];
          if (output != null) {
            relativeParts.add(output);
          }
          final FileInfo fileInfo = FileInfo(
            export: p
                .relative(filePath, from: p.joinAll(relativeParts))
                .replaceAll('\\', '/'),
            packageName: packageNode.name,
          );

          final CompilationUnitElement fileElement =
              await getElement(context.currentSession, filePath);

          for (final ClassElement classElement in fileElement.classes) {
            findFFRoute(fileInfo, classElement);
          }

          await _handleFunctionWidget(
              fileElement, typeChecker, context, fileInfo);

          if (fileInfo.routes.isNotEmpty) {
            for (final LibraryImportElement importElement
                in fileElement.library.libraryImports) {
              final DartObject? fFArgumentImportAnnotation =
                  fFArgumentImportTypeChecker.firstAnnotationOf(importElement);

              // if (importElement.prefix != null) {
              //   fileInfo.importPrefixMap[importElement.prefix!.element.name] =
              //       importElement;
              // }

              if (fFArgumentImportAnnotation != null) {
                final ConstantReader reader =
                    ConstantReader(fFArgumentImportAnnotation);
                fileInfo.routes.first.addImport(importElement, reader: reader);
              }
            }

            fileInfoList.add(fileInfo);
          }
        }
      }
    }
  }

  Future<void> _handleFunctionWidget(
      CompilationUnitElement fileElement,
      TypeChecker typeChecker,
      AnalysisContext context,
      FileInfo fileInfo) async {
    final Map<String, DartObject> _widgetFunctionMap = <String, DartObject>{};

    for (final FunctionElement functionElement in fileElement.functions) {
      final DartObject? annotation =
          typeChecker.firstAnnotationOf(functionElement);
      final DartObject? functionalWidget =
          functionalWidgetTypeChecker.firstAnnotationOf(functionElement);
      if (annotation != null && functionalWidget != null) {
        _widgetFunctionMap[funcName2ClassName(functionElement.name)] =
            annotation;
      }
    }

    if (_widgetFunctionMap.isNotEmpty) {
      for (final PartElement partElement in fileElement.library.parts2) {
        print(partElement.toString());
        final DirectiveUri uri = partElement.uri;
        String? path;
        if (uri is DirectiveUriWithUnit) {
          path = '${uri.unit.source.fullName}';
        } else if (uri is DirectiveUriWithSource) {
          path = '${uri.source.fullName}';
        }
        if (path != null) {
          final CompilationUnitElement element =
              await getElement(context.currentSession, path);
          for (final ClassElement classElement in element.classes) {
            if (_widgetFunctionMap.containsKey(classElement.name)) {
              final DartObject? annotation =
                  _widgetFunctionMap[classElement.name];
              findFFRoute(fileInfo, classElement, annotation: annotation);
            }
          }
        }
      }
    }
  }

  Future<CompilationUnitElement> getElement(
      AnalysisSession analysisSession, String path) async {
    return (await analysisSession.getUnitElement(path) as UnitElementResult)
        .element;
  }

  void findFFRoute(FileInfo fileInfo, ClassElement classElement,
      {DartObject? annotation}) {
    annotation ??= fFRouteTypeChecker.firstAnnotationOf(classElement);
    if (annotation != null) {
      final ConstantReader reader = ConstantReader(annotation);

      print(
          'Found annotation route in ${classElement.source.uri} ------ class : ${classElement.displayName}');

      final ConstantReader? exts = reader.peek('exts');
      Map<String, String>? extsMap;
      if (exts != null) {
        final ElementAnnotationImpl? elementAnnotation = classElement.metadata
            .firstWhereOrNull((ElementAnnotation element) =>
                (element as ElementAnnotationImpl).annotationAst.name.name ==
                typeOf<FFRoute>().toString()) as ElementAnnotationImpl?;
        final NodeList<Expression>? parameters =
            elementAnnotation?.annotationAst.arguments?.arguments;

        if (parameters != null) {
          for (final Expression item in parameters) {
            if (item is NamedExpressionImpl) {
              String source;
              source = item.expression.toSource();
              if (source == 'null') {
                continue;
              }
              final String key = item.name.toSource();
              if (key == 'exts:') {
                if (item.expression is SetOrMapLiteralImpl) {
                  final SetOrMapLiteralImpl setOrMapLiteralImpl =
                      item.expression as SetOrMapLiteralImpl;
                  if (setOrMapLiteralImpl.elements.isNotEmpty) {
                    extsMap = <String, String>{};
                    for (final CollectionElement element
                        in setOrMapLiteralImpl.elements) {
                      final MapLiteralEntryImpl entry =
                          element as MapLiteralEntryImpl;
                      final String value = entry.value.toString();

                      extsMap[entry.key.toString()] = value;
                    }
                  }
                }
                break;
              }
            }
          }
        }
      }

      final List<String>? argumentImports = reader
          .peek('argumentImports')
          ?.listValue
          .map((DartObject e) => e.toStringValue()!)
          .toList();
      if (argumentImports != null) {
        FileInfo.imports.addAll(argumentImports);
      }

      DartTypeAutoImportHelper().findParametersImport(classElement);

      final RouteInfo routeInfo = RouteInfo(
        className: classElement.displayName,
        ffRoute: FFRoute(
          name: reader.read('name').stringValue,
          showStatusBar: reader.peek('showStatusBar')?.boolValue ?? true,
          routeName: reader.peek('routeName')?.stringValue ?? '',
          pageRouteType: PageRouteType.values.firstWhereOrNull(
            (PageRouteType type) =>
                type.name ==
                reader.peek('pageRouteType')?.objectValue.variable?.displayName,
          ),
          description: reader.peek('description')?.stringValue ?? '',
          exts: extsMap,
          // exts: reader.peek('exts')?.mapValue.map<String, dynamic>(
          //     (DartObject? key, DartObject? value) => MapEntry<String, dynamic>(
          //           _getStringValue(key as DartObjectImpl?),
          //           _getStringValue(value as DartObjectImpl?),
          //         )),
          // argumentImports: reader
          //         .peek('argumentImports')
          //         ?.listValue
          //         .map((DartObject e) => e.toStringValue()!)
          //         .toList() ??
          //     <String>[],
          //codes: codesMap,
          codes: reader.peek('codes')?.mapValue.map<String, String>(
              (DartObject? key, DartObject? value) => MapEntry<String, String>(
                  _getStringValue(key as DartObjectImpl?),
                  value!.toStringValue()!)),
        ),
        classElement: classElement,
        fileInfo: fileInfo,
      );

      fileInfo.routes.add(routeInfo);
    }
  }

  String _getStringValue(DartObjectImpl? object) {
    if (object == null) {
      return '';
    }
    final String valueString = object
        .toString()
        .replaceFirst(object.type.getDisplayString(withNullability: true), '')
        .trim();
    // toString() = "${type.getDisplayString(withNullability: false)} ($_state)";

    return valueString.substring(1, valueString.length - 1);
  }
}
