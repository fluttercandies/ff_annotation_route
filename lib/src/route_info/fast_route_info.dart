import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'route_info_base.dart';

class FastRouteInfo extends RouteInfoBase {
  FastRouteInfo({
    required super.ffRoute,
    required super.className,
    this.routePath,
    required this.classDeclaration,
    required super.fileInfo,
  })  : constructors = classDeclaration.members
            .whereType<ConstructorDeclaration>()
            .toList(),
        fields =
            classDeclaration.members.whereType<FieldDeclaration>().toList();

  final List<ConstructorDeclaration> constructors;
  final List<FieldDeclaration> fields;

  final String? routePath;
  final Map<String?, List<String>> constructorsMap = <String?, List<String>>{};
  final ClassDeclaration classDeclaration;

  @override
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

  @override
  String get constructor {
    //remove private constructor
    constructors.removeWhere(
        (ConstructorDeclaration element) => element.name?.toString() == '_');
    if (constructors.isNotEmpty) {
      if (constructors.length > 1) {
        String switchCase = '';
        String defaultCtor = '';
        for (final ConstructorDeclaration rawConstructor in constructors) {
          final String ctorName = rawConstructor.name?.toString() ?? '';
          if (ctorName.isEmpty) {
            defaultCtor = '''
case '':
default:
return ${getConstructorString(rawConstructor)};
''';
          } else {
            switchCase += '''
              case '$ctorName':
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
              safeArguments[constructorName${Args().argumentsIsCaseSensitive ? '' : '.toLowerCase()'}]?.toString() ?? '';
         switch (ctorName) {
            $switchCase
          }
         }
        ''';

        return switchCase;
      } else {
        return ' () =>  ${getConstructorString(constructors.first)}';
      }
    }
    return '() =>$classNameConflictPrefixText$className()';
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
      value = '$name:$value';
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
      constructorString = 'const $constructorString';
    }
    return constructorString;
  }

  String getParameterType(String name, FormalParameter parameter,
      ConstructorDeclaration rawConstructor) {
    String? typeString;
    if (parameter.toString().contains('this.')) {
      for (final FieldDeclaration item in fields) {
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
        classDeclaration.parent as CompilationUnit;
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
    if (rawConstructor.name != null) {
      ctor += '.${rawConstructor.name.toString()}';
    }
    return classNameConflictPrefixText + ctor;
  }

  @override
  String? getArgumentsClass() {
    constructors.removeWhere(
        (ConstructorDeclaration element) => element.name?.toString() == '_');
    if (constructors.isNotEmpty) {
      final StringBuffer sb = StringBuffer();
      for (final ConstructorDeclaration rawConstructor in constructors) {
        final String? name = rawConstructor.name?.toString();
        final FormalParameterList parameters = rawConstructor.parameters;
        if (name == null && parameters.parameters.isEmpty) {
          continue;
        }
        String args = parameters.toString();
        String nameMap = '';
        final List<String> parameterNames = <String>[];
        for (final FormalParameter parameter in parameters.parameters) {
          final String parameterS = parameter.toString();
          final String? name = parameter.name?.toString();
          if (parameterS.contains('this.')) {
            for (final FieldDeclaration item in fields) {
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
          parameterNames.add('\'$name\'');
        }
        if (name != null) {
          nameMap += ''''$constructorName':'$name',''';
        }
        if (Args().enableSuperArguments && Args().enableArgumentNames) {
          nameMap += ''''$argumentNames':<String>$parameterNames,''';
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
