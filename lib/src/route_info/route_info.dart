import 'package:analyzer/dart/element/element.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

import '/src/arg/args.dart';
import '/src/utils/dart_type_auto_import.dart';
import 'route_info_base.dart';

class RouteInfo extends RouteInfoBase {
  RouteInfo({
    required super.ffRoute,
    required super.className,
    required this.classElement,
    required super.fileInfo,
    required this.element,
  }) : constructors =
           classElement.constructors
               .where((e) => e.name.toString() != '_')
               .toList();

  final ClassElement classElement;
  final List<ConstructorElement> constructors;
  final LibraryFragment element;

  String _constructorName(ConstructorElement constructor) {
    final String name = constructor.name ?? '';
    return name == 'new' ? '' : name;
  }

  List<String> get prefixes =>
      element.prefixes.map((PrefixElement e) => e.displayName).toList();

  @override
  String? get constructorsString {
    if (constructors.isNotEmpty) {
      String temp = '';
      for (final ConstructorElement rawConstructor in constructors) {
        if (constructors.length == 1 &&
            rawConstructor.formalParameters.isEmpty &&
            _constructorName(rawConstructor).isEmpty) {
          return null;
        }

        String args =
            rawConstructor
                .displayString(multiline: false, preferTypeAlias: true)
                .replaceFirst(rawConstructor.returnType.toString(), '')
                .trim();
        if (!args.startsWith(className)) {
          args = '$className$args';
        }

        temp += '\n /// \n /// $args';
      }
      return temp;
    }

    return null;
  }

  @override
  String get constructor {
    final String arguments =
        Args().isGoRouterOutputTemplate
            ? 'Map<String, dynamic> safeArguments'
            : '';
    if (constructors.isNotEmpty) {
      if (constructors.length > 1) {
        String switchCase = '';
        String defaultCtor = '';
        for (final ConstructorElement rawConstructor in constructors) {
          final String ctorName = _constructorName(rawConstructor);
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
        return ' ($arguments) =>  ${getConstructorString(constructors.first)}';
      }
    }
    return '($arguments) =>$classNameConflictPrefixText$className()';
  }

  String getIsOptional(
    String name,
    FormalParameterElement parameter,
    ConstructorElement rawConstructor,
  ) {
    String value =
        'safeArguments'
        '[\'${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}\']';

    final String type = getParameterType(parameter);
    final asTBuffer = StringBuffer('asT');
    if (type != 'dynamic') {
      asTBuffer.write('<$type>');
    }
    asTBuffer.write('(');

    value = '$asTBuffer$value';

    final String? defaultValueCode = DartTypeAutoImportHelper()
        .getDefaultValueString(parameter, prefixes);

    if (defaultValueCode != null) {
      value += ',$defaultValueCode';
    }

    value += ',)';
    if (Args().enableNullSafety && !type.endsWith('?') && type != 'dynamic') {
      value += '!';
    }

    if (!parameter.isPositional) {
      value = '$name:$value';
    }
    return value;
  }

  String getConstructorString(ConstructorElement rawConstructor) {
    String constructorString = '';

    constructorString = getConstructor(rawConstructor);

    constructorString += '(';
    bool hasParameters = false;

    //final List<FormalParameter> optionals = <FormalParameter>[];

    for (final FormalParameterElement item in rawConstructor.formalParameters) {
      final String name = item.name!;
      hasParameters = true;
      if (item.isOptional || item.isRequiredNamed) {
        constructorString += getIsOptional(name, item, rawConstructor);
        // if (!item.isRequired) {
        //   optionals.add(item);
        // }
      } else {
        final String type = getParameterType(item);

        constructorString +=
            'asT<$type>(safeArguments[\''
            '${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}'
            '\'],)';
        if (Args().enableNullSafety && !type.endsWith('?')) {
          constructorString += '!';
        }
      }

      constructorString += ',';
    }

    constructorString += ')';

    if (rawConstructor.isConst && !hasParameters) {
      constructorString = 'const $constructorString';
    }
    return constructorString;
  }

  String getParameterType(FormalParameterElement parameter) {
    return DartTypeAutoImportHelper().fixDartTypeString(parameter.type);
  }

  String getConstructor(ConstructorElement rawConstructor) {
    String ctor = className;
    final String name = _constructorName(rawConstructor);
    if (name.isNotEmpty) {
      ctor += '.$name';
    }

    return classNameConflictPrefixText + ctor;
  }

  @override
  String? getArgumentsClass() {
    constructors.removeWhere(
      (ConstructorElement element) => _constructorName(element) == '_',
    );
    if (constructors.isNotEmpty) {
      final StringBuffer sb = StringBuffer();

      for (final ConstructorElement rawConstructor in constructors) {
        final String name = _constructorName(rawConstructor);
        if (constructors.length == 1 &&
            name.isEmpty &&
            rawConstructor.formalParameters.isEmpty) {
          // only one ctor and no parameters
          // no need arguments class
          return null;
        }

        String args = DartTypeAutoImportHelper().getFormalParameters(
          rawConstructor.formalParameters,
          prefixes,
        );

        String nameMap = '';
        final List<String> parameterNames = <String>[];
        for (final FormalParameterElement parameter
            in rawConstructor.formalParameters) {
          final String name = parameter.name!;
          if (!Args().enableNullSafety) {
            args = args.replaceAll('?', '');
          }
          nameMap += ''''$name':$name,''';
          parameterNames.add('\'$name\'');
        }

        nameMap += ''''$constructorName':'$name',''';
        if (Args().enableSuperArguments && Args().enableArgumentNames) {
          nameMap += ''''$argumentNames':<String>$parameterNames,''';
        }

        sb.write(
          routeConstClassMethodTemplate
              .replaceAll(
                '{0}',
                (name.isEmpty ? 'd' : name) + args,
              )
              .replaceAll('{1}', nameMap)
              .replaceAll(
                '{2}',
                rawConstructor.formalParameters.isEmpty ? 'const' : '',
              ),
        );
      }

      if (sb.isNotEmpty) {
        argumentsClass = sb.toString();
        return argumentsClass;
      }
    }

    return null;
  }
}
