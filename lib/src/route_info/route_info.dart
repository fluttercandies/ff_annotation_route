// ignore_for_file: implementation_imports

import 'package:analyzer/dart/element/element.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route/src/file_info.dart';
import 'package:ff_annotation_route/src/utils/dart_type_auto_import.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'route_info_base.dart';
import 'package:analyzer/src/dart/element/type.dart';

class RouteInfo extends RouteInfoBase {
  RouteInfo({
    required FFRoute ffRoute,
    required String className,
    required this.classElement,
    required FileInfo fileInfo,
  }) : super(
          className: className,
          ffRoute: ffRoute,
          fileInfo: fileInfo,
        );

  final ClassElement classElement;
  List<ConstructorElement> get constructors => classElement.constructors;

  @override
  String? get constructorsString {
    if (constructors.isNotEmpty) {
      String temp = '';
      for (final ConstructorElement rawConstructor in constructors) {
        if (constructors.length == 1 &&
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

  @override
  String get constructor {
    constructors.removeWhere(
        (ConstructorElement element) => element.name.toString() == '_');

    if (constructors.isNotEmpty) {
      if (constructors.length > 1) {
        String switchCase = '';
        String defaultCtor = '';
        for (final ConstructorElement rawConstructor in constructors) {
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
        return ' () =>  ${getConstructorString(constructors.first)}';
      }
    }
    return '() =>' + classNameConflictPrefixText + '$className()';
  }

  String getIsOptional(String name, ParameterElement parameter,
      ConstructorElement rawConstructor) {
    String value =
        'safeArguments[\'${Args().argumentsIsCaseSensitive ? name : name.toLowerCase()}\']';

    final String type = getParameterType(parameter);

    value = 'asT<$type>($value';

    if (parameter.defaultValueCode != null) {
      value += ',${DartTypeAutoImportHelper().fixDefaultValueCodeString(
        parameter.defaultValueCode!,
        parameter.type,
      )}';
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
    return DartTypeAutoImportHelper()
        .fixDartTypeString(parameter.type as InterfaceTypeImpl);
  }

  String getConstructor(ConstructorElement rawConstructor) {
    String ctor = className;
    if (rawConstructor.name.isNotEmpty) {
      ctor += '.${rawConstructor.name}';
    }

    return classNameConflictPrefixText + ctor;
  }

  @override
  String? getArgumentsClass() {
    constructors
        .removeWhere((ConstructorElement element) => element.name == '_');
    if (constructors.isNotEmpty) {
      final StringBuffer sb = StringBuffer();

      for (final ConstructorElement rawConstructor in constructors) {
        final String name = rawConstructor.name;
        if (constructors.length == 1 &&
            name.isEmpty &&
            rawConstructor.parameters.isEmpty) {
          // only one ctor and no parameters
          // no need arguments class
          return null;
        }
        String args = DartTypeAutoImportHelper()
            .getFormalParameters(rawConstructor.parameters);

        String nameMap = '';
        for (final ParameterElement parameter in rawConstructor.parameters) {
          final String name = parameter.name;
          if (!Args().enableNullSafety) {
            args = args.replaceAll('?', '');
          }
          nameMap += ''''$name':$name,''';
        }

        nameMap += ''''$constructorName':'$name',''';

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
