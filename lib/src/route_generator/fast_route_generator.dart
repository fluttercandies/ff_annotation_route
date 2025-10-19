import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route/src/utils/ff_route.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:path/path.dart' as p;

import '/src/arg/args.dart';
import '/src/file_info.dart';
import '/src/route_info/fast_route_info.dart';
import '/src/template.dart';
import '/src/utils/convert.dart';
import '/src/utils/route_interceptor.dart';
import 'route_generator_base.dart';

class FastRouteGenerator extends RouteGeneratorBase {
  FastRouteGenerator({
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
      for (final file in lib!.listSync(recursive: true)) {
        if (file is io.File && file.path.endsWith('.dart')) {
          final ParseStringResult result = parseFile(
            path: file.path,
            featureSet: FeatureSet.latestLanguageVersion(),
          );
          final CompilationUnit astRoot = result.unit;
          final ffRouteFileImportPath =
              'package:${[
                packageName,
                ...file.path.replaceFirst(lib!.path, '').split(p.context.separator).where((element) => element.isNotEmpty),
              ].join('/')}';
          final List<String> argumentImports = <String>[];
          for (final child in astRoot.childEntities) {
            if (child is ImportDirective) {
              final syntacticEntity = child.childEntities.firstWhereOrNull(
                (SyntacticEntity element) => element is Annotation,
              );

              if (syntacticEntity != null) {
                final Annotation annotation = syntacticEntity as AnnotationImpl;
                if (annotation.name.name ==
                        typeOf<FFArgumentImport>().toString() ||
                    annotation.name.name == typeOf<FFAutoImport>().toString()) {
                  final NodeList<Expression>? parameters =
                      annotation.arguments?.arguments;
                  String import = child.toString().replaceAll(
                    annotation.toString(),
                    '',
                  );
                  import = import.replaceAll(';', '');
                  if (parameters != null && parameters.isNotEmpty) {
                    import =
                        '$import ${parameters.first.toString().replaceAll('\'', '')}';
                  }
                  import += ';\n';
                  argumentImports.add(import);
                }
              }
            }
          }

          FileInfo? fileInfo;
          for (final declaration in astRoot.declarations) {
            for (final metadata in declaration.metadata) {
              final ClassDeclaration? ffRefClassDef =
                  getFFRouteRefClassDeclaration(metadata, file);
              if (ffRefClassDef != null) {
                final String className = ffRefClassDef.name.toString();
                final String routePath =
                    '${p.relative(file.path, from: lib!.parent.path)}'
                    ' ------ class : $className';
                print('Found annotation route : $routePath');

                final List<String> relativeParts = <String>[
                  lib!.parent.path,
                  'lib',
                ];
                if (output != null) {
                  relativeParts.add(output);
                }

                fileInfo ??= FileInfo(
                  export: p
                      .relative(file.path, from: p.joinAll(relativeParts))
                      .replaceAll(r'\', '/'),
                  packageName: packageName,
                );

                final NodeList<Expression>? parameters =
                    metadata.arguments?.arguments;
                if (parameters == null) {
                  continue;
                }
                final GeneratedFFRoute ffRoute = getFFRouteFromAnnotation(
                  parameters,
                  argumentImports,
                  ffRouteFileImportPath,
                  packageName,
                );

                final FastRouteInfo routeInfo = FastRouteInfo(
                  className: className,
                  ffRoute: ffRoute,
                  routePath: routePath,
                  classDeclaration: ffRefClassDef,
                  fileInfo: fileInfo,
                );
                fileInfo.routes.add(routeInfo);
              }
            }
          }
          if (fileInfo != null) {
            fileInfoList.add(fileInfo);
          }
        }
      }
    }
  }

  GeneratedFFRoute getFFRouteFromAnnotation(
    NodeList<Expression> parameters,
    List<String> argumentImports,
    String ffRouteFileImportPath,
    String packageName,
  ) {
    String? name;
    bool? showStatusBar;
    String? routeName;
    PageRouteType? pageRouteType;
    String? description;
    Map<String, dynamic>? exts;
    Map<String, String>? codes;
    List<FFRouteInterceptor>? interceptors;
    List<InterceptorType>? interceptorTypes;

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
            argumentImports.addAll(toT<List<String>>(item.expression)!);
            break;
          case 'exts:':
          case 'codes:':
            if (item.expression is SetOrMapLiteralImpl) {
              final SetOrMapLiteralImpl setOrMapLiteralImpl =
                  item.expression as SetOrMapLiteralImpl;
              final bool isCodes = key == 'codes:';
              if (setOrMapLiteralImpl.elements.isNotEmpty) {
                final Map<String, dynamic> map =
                    isCodes
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
            break;
          case 'interceptors:':
            if (item.expression is ListLiteralImpl) {
              for (final CollectionElementImpl element
                  in (item.expression as ListLiteralImpl).elements) {
                if (element is MethodInvocationImpl) {
                  interceptors ??= <FFRouteInterceptor>[];
                  interceptors.add(
                    FFRouteInterceptor(
                      className: element.methodName.name,
                    ),
                  );
                }
              }
            }
            break;
          case 'interceptorTypes:':
            if (item.expression is ListLiteralImpl) {
              for (final CollectionElementImpl element
                  in (item.expression as ListLiteralImpl).elements) {
                if (element is SimpleIdentifierImpl) {
                  interceptorTypes ??= <InterceptorType>[];
                  interceptorTypes.add(
                    InterceptorType(
                      className: element.name,
                    ),
                  );
                }
              }
            }
            break;
        }
      }
    }

    final bool generateFilePath = Args().generateFileImport;
    final List<String>? generateFileImportPackages =
        Args().generateFileImportPackages.value;
    if (generateFilePath &&
        (generateFileImportPackages == null ||
            generateFileImportPackages.contains(packageName))) {
      exts ??= <String, dynamic>{};

      exts['\'$ffRouteFileImport\''] = '\'$ffRouteFileImportPath\'';
    }

    final GeneratedFFRoute ffRoute = GeneratedFFRoute(
      name: name!,
      showStatusBar: showStatusBar ?? true,
      routeName: routeName ?? '',
      pageRouteType: pageRouteType,
      description: description ?? '',
      exts: exts,
      argumentImports: argumentImports,
      codes: codes,
      interceptors: interceptors,
      interceptorTypeStrings: interceptorTypes,
    );
    return ffRoute;
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
    io.FileSystemEntity file,
  ) {
    if (metadata.name.name == typeOf<FFRoute>().toString()) {
      final AstNode node = metadata.parent;
      if (node is ClassDeclaration) {
        return node;
      } else if (node is FunctionDeclaration) {
        final bool isFuncWidget = node.metadata.any(
          (Annotation e) => _functionalWidgetAnnotations.contains(e.name.name),
        );
        if (isFuncWidget) {
          final Iterable<PartDirective> parts =
              (node.parent as CompilationUnit).directives
                  .whereType<PartDirective>();
          final String funcName = node.name.toString();
          final String className = funcName2ClassName(funcName);
          for (final PartDirective part in parts) {
            final String join = p.join(file.parent.path, part.uri.stringValue!);
            final String path = p.normalize(join);
            final Iterable<ClassDeclaration> classes;
            if (_partClassDeclarations.containsKey(path)) {
              classes = _partClassDeclarations[path]!;
            } else {
              final CompilationUnit astRoot =
                  parseFile(
                    path: path,
                    featureSet: FeatureSet.latestLanguageVersion(),
                  ).unit;
              classes = astRoot.declarations.whereType<ClassDeclaration>();
              _partClassDeclarations[path] = classes;
            }
            final ClassDeclaration? find = classes.firstWhereOrNull(
              (ClassDeclaration clazz) => clazz.name.toString() == className,
            );
            if (find != null) {
              return find;
            }
          }
          throw StateError(
            '[$className] class not found, please run `flutter pub run build_runner build` before execute this.',
          );
        }
      }
    }
    return null;
  }
}
