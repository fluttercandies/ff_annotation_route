import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:ff_annotation_route/src/file_info.dart';
import 'package:ff_annotation_route/src/utils/camel_under_score_converter.dart';
import 'package:ff_annotation_route/src/utils/convert.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:source_gen/source_gen.dart';

abstract class RouteInfoBase {
  RouteInfoBase({
    required this.ffRoute,
    required this.className,
    required this.fileInfo,
  });

  final String className;
  final FFRoute ffRoute;
  final FileInfo fileInfo;
  String? classNameConflictPrefix;

  String get classNameConflictPrefixText =>
      classNameConflictPrefix != null ? '$classNameConflictPrefix.' : '';

  String? get constructorsString;

  String get constructor;

  String get caseString {
    String codes = '';
    if (ffRoute.codes != null && ffRoute.codes!.isNotEmpty) {
      codes += 'codes: <String,dynamic>{';

      for (final String key in ffRoute.codes!.keys) {
        codes += '$key:${ffRoute.codes![key]},';
      }
      codes += '},';
    }

    String exts = '';
    if (ffRoute.exts != null && ffRoute.exts!.isNotEmpty) {
      exts += 'exts: <String,dynamic>{';

      for (final String key in ffRoute.exts!.keys) {
        exts += '$key:${ffRoute.exts![key]},';
      }
      exts += '},';
    }

    return '''case ${safeToString(ffRoute.name)}:

    return FFRouteSettings(
      name: name,
      arguments: arguments,
      builder: $constructor,
      $codes
      ${ffRoute.showStatusBar != true ? 'showStatusBar: ${ffRoute.showStatusBar},' : ''}
      ${ffRoute.routeName != '' ? 'routeName: ${safeToString(ffRoute.routeName)},' : ''}
      ${ffRoute.pageRouteType != null ? 'pageRouteType: ${ffRoute.pageRouteType},' : ''}
      ${ffRoute.description != '' ? 'description: ${safeToString(ffRoute.description)},' : ''}
      $exts
      );\n''';
  }

  @override
  String toString() {
    return 'RouteInfo {className: $className, ffRoute: $ffRoute}';
  }

  void getRouteConst(bool enableSuperArguments, StringBuffer sb) {
    final FFRoute route = ffRoute;

    final String name = safeToString(route.name)!;
    final String routeName = safeToString(route.routeName)!;
    final String description = safeToString(route.description)!;
    final String? constructor = constructorsString;
    final bool showStatusBar = route.showStatusBar;
    final PageRouteType? pageRouteType = route.pageRouteType;
    final Map<String, dynamic>? exts = route.exts;

    final String firstLine = description == "''"
        ? (routeName == "''" ? name : routeName)
        : description;

    String constant = camelName(name)
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('://', '_')
        .replaceAll('/', '_')
        .replaceAll('.', '_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    while (constant.startsWith('_')) {
      constant = constant.replaceFirst('_', '');
    }
    if (name.replaceAll('\'', '') == '/') {
      constant = 'root';
    }

    sb.write('/// $firstLine\n');
    sb.write('///');
    sb.write('\n/// [name] : $name');
    if (routeName != "''") {
      sb.write('\n///');
      sb.write('\n/// [routeName] : $routeName');
    }
    if (description != "''") {
      sb.write('\n///');
      sb.write('\n/// [description] : $description');
    }
    if (constructor != null) {
      sb.write('\n///');
      sb.write('\n/// [constructors] : $constructor');
    }
    if (showStatusBar != true) {
      sb.write('\n///');
      sb.write('\n/// [showStatusBar] : $showStatusBar');
    }
    if (pageRouteType != null) {
      sb.write('\n///');
      sb.write('\n/// [pageRouteType] : $pageRouteType');
    }

    if (exts != null) {
      sb.write('\n///');
      sb.write('\n/// [exts] : $exts');
    }

    if (enableSuperArguments && getArgumentsClass() != null) {
      String argumentsClassName = camelName(constant);
      if (argumentsClassName.length == 1) {
        argumentsClassName = argumentsClassName.toUpperCase();
      } else {
        argumentsClassName = argumentsClassName[0].toUpperCase() +
            argumentsClassName.substring(1, argumentsClassName.length);
      }
      argumentsClassName = '_$argumentsClassName';
      sb.write(
        '\nstatic const $argumentsClassName '
        '${camelName(constant)} = $argumentsClassName();\n\n',
      );

      argumentsClass = routeConstClassTemplate
          .replaceAll('{0}', argumentsClassName)
          .replaceAll('{1}', name)
          .replaceAll('{2}', argumentsClass!);
    } else {
      sb.write(
        '\nstatic const String '
        '${camelName(constant)} = $name;\n\n',
      );
    }
  }

  String? argumentsClass;

  String? getArgumentsClass();

  void addImport(
    LibraryImportElement importElement, {
    ConstantReader? reader,
    bool containsCombinator = true,
    DartType? type,
  }) {
    final DirectiveUriWithLibraryImpl url =
        importElement.uri as DirectiveUriWithLibraryImpl;
    // ignore
    if (url.relativeUriString == 'dart:core') {
      return;
    }

    String importString = '\'${url.source.uri}\'';

    String suffix = reader?.peek('suffix')?.stringValue.trim() ?? '';
    if (containsCombinator) {
      for (final NamespaceCombinator combinator in importElement.combinators) {
        String combinatorString = combinator.toString();
        if (combinator is HideElementCombinatorImpl) {
          // bug
          combinatorString = combinatorString.replaceFirst('show', 'hide');
        }
        suffix += ' $combinatorString';
      }
    }
    String prefix = '';
    if (importElement.prefix != null) {
      prefix = ' ${importElement.prefix!.element.toString()}';
    }

    importString = '${'import $importString$suffix$prefix'.trim()};';

    if (!FileInfo.imports.contains(importString)) {
      if (type != null) {
        print(
          'Automatically import for type($type) in file '
          '${fileInfo.export}: $importString ',
        );
      }

      FileInfo.imports.add(importString);
    }
  }
}

const String routeConstClassMethodTemplate =
    'Map<String, dynamic> {0} => {2} <String, dynamic>{{1}};\n\n';

const String routeConstClassTemplate = '''
class {0} {

  const {0}();

  String get name => {1};

  {2}

  @override
  String toString() => name;
}
''';
