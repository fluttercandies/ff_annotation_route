import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/constant/value.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route/src/utils/ff_route.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

import '/src/arg/args.dart';
import '/src/file_info.dart';
import '/src/route_info/route_info.dart';
import '/src/template.dart';
import '/src/utils/dart_type_auto_import.dart';
import '/src/utils/route_interceptor.dart';
import 'route_generator_base.dart';

const fFRouteTypeChecker = TypeChecker.typeNamed(FFRoute);
const fFArgumentImportTypeChecker = TypeChecker.typeNamed(FFArgumentImport);
const fFAutoImportTypeChecker = TypeChecker.typeNamed(FFAutoImport);
const functionalWidgetTypeChecker = TypeChecker.fromUrl(
  'package:functional_widget_annotation'
  '/functional_widget_annotation.dart'
  '#FunctionalWidget',
);

class RouteGenerator extends RouteGeneratorBase {
  RouteGenerator({
    required super.packageName,
    required super.packagePath,
    required super.isRoot,
  });

  @override
  Future<void> scanLib({
    String? output,
    AnalysisContextCollection? collection,
  }) async {
    if (lib != null) {
      print('');
      print('Scanning package : $packageName');
      final String libPath = lib!.path;
      collection ??= AnalysisContextCollection(
        includedPaths: <String>[libPath],
        resourceProvider: PhysicalResourceProvider.INSTANCE,
      );
      final AnalysisContext context = collection.contextFor(libPath);

      print('Analyzing ${context.contextRoot.root.path} ...');
      for (final String filePath in context.contextRoot.analyzedFiles()) {
        if (!filePath.endsWith('.dart')) {
          continue;
        }

        final List<String> relativeParts = <String>[lib!.parent.path, 'lib'];
        if (output != null) {
          relativeParts.add(output);
        }
        final FileInfo fileInfo = FileInfo(
          export: p
              .relative(filePath, from: p.joinAll(relativeParts))
              .replaceAll(r'\', '/'),
          packageName: packageName,
        );
        final String ffRouteFileImportPath =
            'package:${<String>[
              packageName,
              ...filePath.replaceFirst(lib!.path, '').split(p.context.separator).where((String element) => element.isNotEmpty),
            ].join('/')}';
        final LibraryFragment fileElement = await getElement(
          context.currentSession,
          filePath,
        );

        for (final ClassElement classElement in fileElement.classes.map(
          (ClassFragment e) => e.element,
        )) {
          findFFRoute(
            fileElement,
            fileInfo,
            classElement,
            ffRouteFileImportPath,
            packageName,
          );
        }

        await _handleFunctionWidget(
          fileElement,
          context,
          fileInfo,
          ffRouteFileImportPath,
        );

        if (fileInfo.routes.isNotEmpty) {
          for (final LibraryImport importElement
              in fileElement.libraryImports) {
            _findAutoImport(
              importElement,
              fileInfo,
              fFArgumentImportTypeChecker,
            );
            _findAutoImport(
              importElement,
              fileInfo,
              fFAutoImportTypeChecker,
            );
          }

          fileInfoList.add(fileInfo);
        }
      }
    }
  }

  void _findAutoImport(
    LibraryImport importElement,
    FileInfo fileInfo,
    TypeChecker typeChecker,
  ) {
    final DartObject? fFArgumentImportAnnotation = typeChecker
        .firstAnnotationOf(
          importElement,
          throwOnUnresolved: true,
        );

    if (fFArgumentImportAnnotation != null) {
      final ConstantReader reader = ConstantReader(fFArgumentImportAnnotation);
      fileInfo.routes.first.addImport(importElement, reader: reader);
    }
  }

  Future<void> _handleFunctionWidget(
    LibraryFragment fileElement,
    AnalysisContext context,
    FileInfo fileInfo,
    String ffRouteFileImportPath,
  ) async {
    final widgetFunctionMap = <String, DartObject>{};

    for (final TopLevelFunctionElement functionElement in fileElement.functions
        .map((TopLevelFunctionFragment e) => e.element)) {
      final String? functionName = functionElement.name;
      if (functionName == null) {
        continue;
      }
      final annotation = fFRouteTypeChecker.firstAnnotationOf(
        functionElement,
        throwOnUnresolved: true,
      );
      final functionalWidget = functionalWidgetTypeChecker.firstAnnotationOf(
        functionElement,
        throwOnUnresolved: true,
      );
      if (annotation != null && functionalWidget != null) {
        widgetFunctionMap[funcName2ClassName(functionName)] = annotation;
      }
    }

    if (widgetFunctionMap.isNotEmpty) {
      for (final PartInclude partElement in fileElement.partIncludes) {
        final DirectiveUri uri = partElement.uri;
        String? path;
        if (uri is DirectiveUriWithUnit) {
          path = uri.libraryFragment.source.fullName;
        } else if (uri is DirectiveUriWithSource) {
          path = uri.source.fullName;
        }
        if (path != null) {
          final element = await getElement(context.currentSession, path);
          for (final ClassElement classElement in element.classes.map(
            (ClassFragment e) => e.element,
          )) {
            if (widgetFunctionMap.containsKey(classElement.name)) {
              final DartObject? annotation =
                  widgetFunctionMap[classElement.name];
              findFFRoute(
                element,
                fileInfo,
                classElement,
                ffRouteFileImportPath,
                packageName,
                annotation: annotation,
              );
            }
          }
        }
      }
    }
  }

  Future<LibraryFragment> getElement(
    AnalysisSession analysisSession,
    String path,
  ) async {
    return (await analysisSession.getUnitElement(path) as UnitElementResult)
        .fragment;
  }

  void findFFRoute(
    LibraryFragment element,
    FileInfo fileInfo,
    ClassElement classElement,
    String ffRouteFileImportPath,
    String packageName, {
    DartObject? annotation,
  }) {
    annotation ??= fFRouteTypeChecker.firstAnnotationOf(
      classElement,
      throwOnUnresolved: true,
    );
    GeneratedFFRoute? ffRoute;
    List<String>? argumentImports;
    if (annotation != null) {
      final ConstantReader reader = ConstantReader(annotation);

      print(
        'Found annotation route in ${classElement.library.firstFragment.source.uri} ------ class : ${classElement.displayName}',
      );

      final ConstantReader? exts = reader.peek('exts');
      Map<String, String>? extsMap;
      if (exts != null) {
        final parameters = _getFFRouteParameters(classElement);
        if (parameters != null) {
          for (final Object? item in parameters) {
            final Expression? expression = _argumentExpression(item);
            final String? key = _argumentName(item);
            if (expression != null && key != null) {
              String source;
              source = expression.toSource();
              if (source == 'null') {
                continue;
              }
              if (key == 'exts:') {
                if (expression is SetOrMapLiteral) {
                  final SetOrMapLiteral setOrMapLiteralImpl = expression;
                  if (setOrMapLiteralImpl.elements.isNotEmpty) {
                    extsMap = <String, String>{};
                    for (final CollectionElement element
                        in setOrMapLiteralImpl.elements) {
                      final MapLiteralEntry entry = element as MapLiteralEntry;
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
      argumentImports =
          reader
              .peek('argumentImports')
              ?.listValue
              .map((e) => e.toStringValue()!)
              .toList();
      final bool generateFilePath = Args().generateFileImport;
      final List<String>? generateFileImportPackages =
          Args().generateFileImportPackages.value;
      if (generateFilePath &&
          (generateFileImportPackages == null ||
              generateFileImportPackages.contains(packageName))) {
        extsMap ??= <String, String>{};
        extsMap['\'$ffRouteFileImport\''] = '\'$ffRouteFileImportPath\'';
      }

      ffRoute = GeneratedFFRoute(
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
        codes: reader
            .peek('codes')
            ?.mapValue
            .map<String, String>(
              (key, value) => MapEntry(
                _getStringValue(key as DartObjectImpl?),
                value!.toStringValue()!,
              ),
            ),
        interceptors:
            reader.peek('interceptors')?.listValue.map(
              (e) {
                final DartObjectImpl object = e as DartObjectImpl;
                final dartType = object.type;
                DartTypeAutoImportHelper().findParameterImport(dartType);
                return FFRouteInterceptor(dartType: dartType);
              },
            ).toList(),
        interceptorTypeStrings:
            reader.peek('interceptorTypes')?.listValue.map(
              (e) {
                final DartObjectImpl object = e as DartObjectImpl;
                // InterfaceTypeImpl
                // TypeState
                // TODO(zmtzawqlp): can't get the type of TypeState
                return InterceptorType(
                  className: (object.state as TypeState).toString(),
                );

                // final dartType = (object.type);
                // DartTypeAutoImportHelper().findParameterImport(dartType);
                // return InterceptorType(dartType: dartType);
              },
            ).toList(),
      );
    }

    // else if (classElement.source.uri.toString().contains('.pub-cache')) {
    //   final NodeList<Expression>? parameters =
    //       _getFFRouteParameters(classElement);
    //   if (parameters != null) {
    //     ffRoute =
    //         FastRouteGenerator.getFFRouteFromAnnotation(parameters, <String>[]);
    //     argumentImports = ffRoute.argumentImports;
    //   }
    // }

    if (ffRoute != null) {
      if (argumentImports != null) {
        FileInfo.imports.addAll(argumentImports);
      }

      DartTypeAutoImportHelper().findParametersImport(classElement);
      final RouteInfo routeInfo = RouteInfo(
        className: classElement.displayName,
        ffRoute: ffRoute,
        classElement: classElement,
        fileInfo: fileInfo,
        element: element,
      );

      fileInfo.routes.add(routeInfo);
    }
  }

  NodeList? _getFFRouteParameters(ClassElement classElement) {
    final ElementAnnotation? elementAnnotation = classElement
        .metadata
        .annotations
        .firstWhereOrNull(
          (ElementAnnotation element) =>
              element.toSource().startsWith('@${typeOf<FFRoute>()}'),
        );
    final String? source = elementAnnotation?.toSource();
    if (source == null) {
      return null;
    }
    final int start = source.indexOf('(');
    final int end = source.lastIndexOf(')');
    if (start < 0 || end <= start) {
      return null;
    }
    final ParseStringResult result = parseString(
      content: '$source class _FFRouteAnnotationProbe {}',
    );
    final ClassDeclaration declaration =
        result.unit.declarations.whereType<ClassDeclaration>().first;
    final Annotation annotation = declaration.metadata.first;
    return annotation.arguments?.arguments;
  }

  Expression? _argumentExpression(Object? argument) {
    final dynamic value = argument;
    try {
      return value.argumentExpression as Expression?;
    } on NoSuchMethodError {
      try {
        return value.expression as Expression?;
      } on NoSuchMethodError {
        return argument is Expression ? argument : null;
      }
    }
  }

  String? _argumentName(Object? argument) {
    final dynamic value = argument;
    final Object? name;
    try {
      name = value.name;
    } on NoSuchMethodError {
      return null;
    }
    if (name == null) {
      return null;
    }
    final String text = '$name';
    return text.endsWith(':') ? text : '$text:';
  }

  String _getStringValue(DartObjectImpl? object) {
    if (object == null) {
      return '';
    }
    final String valueString =
        object
            .toString()
            .replaceFirst(
              object.type.getDisplayString(withNullability: true),
              '',
            )
            .trim();
    // toString() = "${type.getDisplayString(withNullability: false)} ($_state)";

    return valueString.substring(1, valueString.length - 1);
  }
}
