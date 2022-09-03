import 'dart:convert';

// ignore_for_file: implementation_imports
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

//import 'package:io/ansi.dart'
import 'route_generator.dart';
import 'utils/camel_under_score_converter.dart';
import 'utils/convert.dart';

class RouteInfo {
  RouteInfo({
    required this.ffRoute,
    required this.className,
    this.constructors,
    this.fields,
    this.routePath,
    this.classDeclaration,
    required this.node,
  });

  final String className;
  final FFRoute ffRoute;
  final List<ConstructorDeclaration>? constructors;
  final List<FieldDeclaration>? fields;
  final String? routePath;
  final Map<String?, List<String>> constructorsMap = <String?, List<String>>{};
  final ClassDeclaration? classDeclaration;
  final RouteGenerator node;

  String? classNameConflictPrefix;

  String get classNameConflictPrefixText =>
      classNameConflictPrefix != null ? '$classNameConflictPrefix.' : '';

  String? get constructorsString {
    if (constructorsMap.isNotEmpty) {
      String temp = '';
      constructorsMap.forEach((String? key, List<String> value) {
        temp += '\n /// \n /// $key : $value';
      });
      return temp;
    }

    return null;
  }

  String get constructor {
    //remove private constructor
    constructors?.removeWhere(
        (ConstructorDeclaration element) => element.name2?.toString() == '_');
    if (constructors != null && constructors!.isNotEmpty) {
      if (constructors!.length > 1) {
        String switchCase = '';
        String defaultCtor = '';
        for (final ConstructorDeclaration rawConstructor in constructors!) {
          final String ctorName = rawConstructor.name2?.toString() ?? '';
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

          // keyValues +=
          //     '\'${rawConstructor.name ?? ''}\': ${getConstructorString(rawConstructor)}';
          // keyValues += ',';
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
        codes += '\'$key\':${ffRoute.codes![key]},';
      }
      codes += '},';
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
      ${ffRoute.exts != null ? 'exts:<String,dynamic>${json.encode(ffRoute.exts)},'.replaceAll('"', '\'') : ''});\n''';
  }

  @override
  String toString() {
    return 'RouteInfo {className: $className, ffRoute: $ffRoute}';
  }

  String getIsOptional(String name, FormalParameter parameter,
      ConstructorDeclaration rawConstructor) {
    String value =
        'safeArguments[\'${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}\']';

    final String type = getParameterType(name, parameter, rawConstructor);

    value = 'asT<$type>($value';

    if (parameter is DefaultFormalParameter && parameter.defaultValue != null) {
      value += ',${parameter.defaultValue}';
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

  String getConstructorString(ConstructorDeclaration rawConstructor) {
    String constructorString = '';

    constructorString = getConstructor(rawConstructor);

    constructorString += '(';
    bool hasParameters = false;

    //final List<FormalParameter> optionals = <FormalParameter>[];

    for (final FormalParameter item in rawConstructor.parameters.parameters) {
      final String? name = item.name?.toString();
      if (name != null) {
        hasParameters = true;
        if (item.isOptional || item.isRequiredNamed) {
          constructorString += getIsOptional(name, item, rawConstructor);
          // if (!item.isRequired) {
          //   optionals.add(item);
          // }
        } else {
          final String type = getParameterType(name, item, rawConstructor);

          constructorString +=
              'asT<$type>(safeArguments[\'${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}\'],)';
          if (Args().enableNullSafety && !type.endsWith('?')) {
            constructorString += '!';
          }
        }

        constructorString += ',';
      }
    }

    constructorString += ')';
    if (!hasParameters) {
      constructorsMap[getConstructor(rawConstructor)] ??= <String>[];
    }

    if (rawConstructor.constKeyword != null && !hasParameters) {
      constructorString = 'const ' + constructorString;
    }
    return constructorString;
  }

  String getParameterType(String name, FormalParameter parameter,
      ConstructorDeclaration rawConstructor) {
    String? typeString;
    if (parameter.toString().contains('this.')) {
      for (final FieldDeclaration item in fields!) {
        if (item.fields.endToken.toString() == name) {
          final TypeAnnotation? type = item.fields.type;
          typeString = type.toString();
          //getTypeImport();
          break;
        }
      }
    } else if (parameter.toString() == 'super.key') {
      return 'Key?';
    } else if (parameter is DefaultFormalParameter &&
        parameter.parameter is SimpleFormalParameter) {
      final TypeAnnotation? type =
          (parameter.parameter as SimpleFormalParameter).type;
      typeString = type.toString();
      //getTypeImport();
    }
    typeString ??= parameter.childEntities.first.toString();
    // if (ffRoute.argumentImports == null) {
    //   alertType(typeString);
    // }

    String display = typeString;
    if (!parameter.isOptional || parameter.toString().contains('required')) {
      display = '$display(required)';
    }

    constructorsMap[getConstructor(rawConstructor)] ??= <String>[];
    constructorsMap[getConstructor(rawConstructor)]!.add('$display $name');
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

  String getConstructor(ConstructorDeclaration rawConstructor) {
    String ctor = className;
    if (rawConstructor.name2 != null) {
      ctor += '.${rawConstructor.name2.toString()}';
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
    constructors?.removeWhere(
        (ConstructorDeclaration element) => element.name2?.toString() == '_');
    if (constructors != null && constructors!.isNotEmpty) {
      final StringBuffer sb = StringBuffer();
      for (final ConstructorDeclaration rawConstructor in constructors!) {
        final String? name = rawConstructor.name2?.toString();
        final FormalParameterList parameters = rawConstructor.parameters;
        if (name == null && parameters.parameters.isEmpty) {
          continue;
        }
        String args = parameters.toString();
        String nameMap = '';
        for (final FormalParameter parameter in parameters.parameters) {
          final String parameterS = parameter.toString();
          final String? name = parameter.name?.toString();
          if (parameterS.contains('this.')) {
            for (final FieldDeclaration item in fields!) {
              if (item.fields.endToken.toString() == name) {
                args = args.replaceFirst(
                  parameterS,
                  parameterS.replaceAll(
                    'this.',
                    '${item.fields.type.toString()} ',
                  ),
                );
                break;
              }
            }
          } else if (parameter.toString() == 'super.key') {
            args = args.replaceFirst(
              parameterS,
              parameterS.replaceAll(
                'super.',
                'Key? ',
              ),
            );
          }
          if (!Args().enableNullSafety) {
            args = args.replaceAll('?', '');
          }
          nameMap += ''''$name':$name,''';
        }
        if (name != null) {
          nameMap += ''''$constructorName':'$name',''';
        }
        if (args.isNotEmpty && parameters.parameters.isNotEmpty) {
          if (args.endsWith('})')) {
            args = args.replaceAll('})', ',})');
          } else if (args.endsWith('])')) {
            args = args.replaceAll('])', ',])');
          } else {
            args = args.replaceAll(')', ',)');
          }
        }

        sb.write(routeConstClassMethodTemplate
            .replaceAll('{0}', (name ?? 'd') + args)
            .replaceAll('{1}', nameMap)
            .replaceAll('{2}',
                rawConstructor.parameters.parameters.isEmpty ? 'const' : ''));
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
