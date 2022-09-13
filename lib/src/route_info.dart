import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'route_generator.dart';
import 'utils/camel_under_score_converter.dart';
import 'utils/convert.dart';

class RouteInfo {
  RouteInfo({
    required this.ffRoute,
    required this.className,
    this.routePath,
    this.classDeclaration,
    required this.node,
    this.constructors,
  });

  final String className;
  final FFRoute ffRoute;
  final String? routePath;
  final ClassDeclaration? classDeclaration;
  final RouteGenerator node;
  final List<ConstructorElement>? constructors;

  String? classNameConflictPrefix;

  String get classNameConflictPrefixText =>
      classNameConflictPrefix != null ? '$classNameConflictPrefix.' : '';

  String? get constructorsString {
    if (constructors != null && constructors!.isNotEmpty) {
      String temp = '';
      for (final ConstructorElement rawConstructor in constructors!) {
        if (constructors!.length == 1 &&
            rawConstructor.parameters.isEmpty &&
            rawConstructor.name.isEmpty) {
          return null;
        }
        final String args = rawConstructor
            .toString()
            .replaceFirst(rawConstructor.returnType.toString(), '')
            .trim();
        temp += '\n /// \n /// $args';
      }
      return temp;
    }

    return null;
  }

  String get constructor {
    constructors?.removeWhere(
        (ConstructorElement element) => element.name.toString() == '_');

    if (constructors != null && constructors!.isNotEmpty) {
      if (constructors!.length > 1) {
        String switchCase = '';
        String defaultCtor = '';
        for (final ConstructorElement rawConstructor in constructors!) {
          final String ctorName = rawConstructor.name;
          if (ctorName.isEmpty) {
            defaultCtor = '''
case '':
default:
return ${getConstructorString(rawConstructor)};
''';
          } else {
            switchCase += '''
              case \'$ctorName\':
              return ${getConstructorString(rawConstructor)};
           ''';
          }
        }
        switchCase += defaultCtor;

        switchCase = '''
         (){
      final String ctorName =
              safeArguments[constructorName${Args().argumentsIsCaseSensitive ? '' : '.toLowerCase()'}]?.toString() ?? \'\';
         switch (ctorName) {
            $switchCase
          }
         }
        ''';

        return switchCase;
      } else {
        return ' () =>  ${getConstructorString(constructors!.first)}';
      }
    }
    return '() =>' + classNameConflictPrefixText + '$className()';
  }

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

  String getIsOptional(String name, ParameterElement parameter,
      ConstructorElement rawConstructor) {
    String value =
        'safeArguments[\'${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}\']';

    final String type = getParameterType(parameter);

    value = 'asT<$type>($value';

    if (parameter.defaultValueCode != null) {
      value += ',${parameter.defaultValueCode}';
    }

    value += ',)';
    if (Args().enableNullSafety && !type.endsWith('?')) {
      value += '!';
    }

    if (!parameter.isPositional) {
      value = '$name:' + value;
    }
    return value;
  }

  String getConstructorString(ConstructorElement rawConstructor) {
    String constructorString = '';

    constructorString = getConstructor(rawConstructor);

    constructorString += '(';
    bool hasParameters = false;

    //final List<FormalParameter> optionals = <FormalParameter>[];

    for (final ParameterElement item in rawConstructor.parameters) {
      final String name = item.name;
      hasParameters = true;
      if (item.isOptional || item.isRequiredNamed) {
        constructorString += getIsOptional(name, item, rawConstructor);
        // if (!item.isRequired) {
        //   optionals.add(item);
        // }
      } else {
        final String type = getParameterType(item);

        constructorString +=
            'asT<$type>(safeArguments[\'${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}\'],)';
        if (Args().enableNullSafety && !type.endsWith('?')) {
          constructorString += '!';
        }
      }

      constructorString += ',';
    }

    constructorString += ')';

    if (rawConstructor.isConst && !hasParameters) {
      constructorString = 'const ' + constructorString;
    }
    return constructorString;
  }

  String getParameterType(ParameterElement parameter) {
    final String typeString = parameter.type.toString();
    return typeString;
  }

  void alertType(String typeString) {
    // final Symbol symbol = Symbol(typeString);
    // final MirrorSystem mirrorSystem = currentMirrorSystem();
    // for (final LibraryMirror value in mirrorSystem.libraries.values) {
    //   if (value.declarations.containsKey(symbol)) {
    //     return;
    //   }
    // }

    // print(red.wrap(
    //     '''Error : '$typeString' must be imported. Please add argumentImports of FFRoute at $routePath.'''));
  }

  void getTypeImport() {
    final CompilationUnit compilationUnit =
        classDeclaration!.parent as CompilationUnit;
    for (final SyntacticEntity item in compilationUnit.childEntities) {
      if (item is ImportDirective) {
        if (item.toString().contains('package:flutter') ||
            item.toString().contains('package:ff_annotation_route')) {
          continue;
        }
        // final ImportDirective importDirective = item;

        // print(item);
      }
    }

    //classDeclarationImpl.parent as
    // final CompilationUnit astRoot = parseFile(
    //   path: '',
    //   featureSet: FeatureSet.fromEnableFlags(<String>[]),
    // ).unit;
    //CompilationUnitImpl
  }

  String getConstructor(ConstructorElement rawConstructor) {
    String ctor = className;
    if (rawConstructor.name.isNotEmpty) {
      ctor += '.${rawConstructor.name}';
    }

    return classNameConflictPrefixText + ctor;
  }

  void getRouteConst(bool enableSuperArguments, StringBuffer sb) {
    final FFRoute _route = ffRoute;

    final String _name = safeToString(_route.name)!;
    final String _routeName = safeToString(_route.routeName)!;
    final String _description = safeToString(_route.description)!;
    final String? _constructors = constructorsString;
    final bool _showStatusBar = _route.showStatusBar;
    final PageRouteType? _pageRouteType = _route.pageRouteType;
    final Map<String, dynamic>? _exts = _route.exts;

    final String _firstLine = _description == "''"
        ? (_routeName == "''" ? _name : _routeName)
        : _description;

    String _constant;
    _constant = camelName(_name)
        .replaceAll('\"', '')
        .replaceAll('\'', '')
        .replaceAll('://', '_')
        .replaceAll('/', '_')
        .replaceAll('.', '_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    while (_constant.startsWith('_')) {
      _constant = _constant.replaceFirst('_', '');
    }
    if (_name.replaceAll('\'', '') == '/') {
      _constant = 'root';
    }

    sb.write('/// $_firstLine\n');
    sb.write('///');
    sb.write('\n/// [name] : $_name');
    if (_routeName != "''") {
      sb.write('\n///');
      sb.write('\n/// [routeName] : $_routeName');
    }
    if (_description != "''") {
      sb.write('\n///');
      sb.write('\n/// [description] : $_description');
    }
    if (_constructors != null) {
      sb.write('\n///');
      sb.write('\n/// [constructors] : $_constructors');
    }
    if (_showStatusBar != true) {
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

    if (enableSuperArguments && _getArgumentsClass() != null) {
      String argumentsClassName = camelName(_constant);
      if (argumentsClassName.length == 1) {
        argumentsClassName = argumentsClassName.toUpperCase();
      } else {
        argumentsClassName = argumentsClassName[0].toUpperCase() +
            argumentsClassName.substring(1, argumentsClassName.length);
      }
      argumentsClassName = '_' + argumentsClassName;
      sb.write(
        '\nstatic const $argumentsClassName '
        '${camelName(_constant)} = $argumentsClassName();\n\n',
      );

      argumentsClass = routeConstClassTemplate
          .replaceAll('{0}', argumentsClassName)
          .replaceAll('{1}', _name)
          .replaceAll('{2}', argumentsClass!);
    } else {
      sb.write(
        '\nstatic const String '
        '${camelName(_constant)} = $_name;\n\n',
      );
    }
  }

  String? argumentsClass;

  String? _getArgumentsClass() {
    constructors
        ?.removeWhere((ConstructorElement element) => element.name == '_');
    if (constructors != null && constructors!.isNotEmpty) {
      final StringBuffer sb = StringBuffer();

      for (final ConstructorElement rawConstructor in constructors!) {
        final String name = rawConstructor.name;
        if (constructors!.length == 1 &&
            name.isEmpty &&
            rawConstructor.parameters.isEmpty) {
          // only one ctor and no parameters
          // no need arguments class
          return null;
        }
        String args = rawConstructor
            .toString()
            .substring(rawConstructor.toString().indexOf('('))
            .trim();

        String nameMap = '';
        for (final ParameterElement parameter in rawConstructor.parameters) {
          final String name = parameter.name;
          if (!Args().enableNullSafety) {
            args = args.replaceAll('?', '');
          }
          nameMap += ''''$name':$name,''';
        }
        //if (name != null) {
        nameMap += ''''$constructorName':'$name',''';
        //}
        if (args.isNotEmpty && rawConstructor.parameters.isNotEmpty) {
          if (args.endsWith('})')) {
            args = args.replaceAll('})', ',})');
          } else if (args.endsWith('])')) {
            args = args.replaceAll('])', ',])');
          } else {
            args = args.replaceAll(')', ',)');
          }
        }

        sb.write(routeConstClassMethodTemplate
            .replaceAll(
                '{0}', (name.isEmpty ? 'd' : rawConstructor.name) + args)
            .replaceAll('{1}', nameMap)
            .replaceAll(
                '{2}', rawConstructor.parameters.isEmpty ? 'const' : ''));
      }

      if (sb.isNotEmpty) {
        argumentsClass = sb.toString();
        return argumentsClass;
      }
    }

    return null;
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
