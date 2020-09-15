import 'dart:convert';
//import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:io/ansi.dart';

import 'utils/convert.dart';

class RouteInfo {
  RouteInfo({
    this.ffRoute,
    this.className,
    this.constructors,
    this.fields,
    this.routePath,
  });

  final String className;
  final FFRoute ffRoute;
  final List<ConstructorDeclaration> constructors;
  final List<FieldDeclaration> fields;
  final String routePath;
  final Map<String, List<String>> constructorsMap = <String, List<String>>{};

  String get constructorsString {
    if (constructorsMap.isNotEmpty) {
      String temp = '';
      constructorsMap.forEach((String key, List<String> value) {
        temp += '\n /// \n /// $key : $value';
      });
      return temp;
    }

    return null;
  }

  String get constructor {
    //remove private constructor
    constructors?.removeWhere(
        (ConstructorDeclaration element) => element.name?.toString() == '_');
    if (constructors != null && constructors.isNotEmpty) {
      if (constructors.length > 1) {
        String keyValues = '';
        for (final ConstructorDeclaration rawConstructor in constructors) {
          keyValues +=
              '\'${rawConstructor.name ?? ''}\': ${getConstructorString(rawConstructor)}';
          keyValues += ',';
        }
        return '<String,Widget>{$keyValues}[arguments[\'constructorName\'] as String ??\'\']';
      } else {
        return '${getConstructorString(constructors.first)}';
      }
    }
    return '$className()';
    // String params = '';
    // if (ffRoute.argumentNames != null && ffRoute.argumentNames.isNotEmpty) {
    //   for (final String key in ffRoute.argumentNames) {
    //     params +=
    //         '${key.replaceAll('\'', '').replaceAll('\"', '')}:arguments[${safeToString(key)}],';
    //   }
    // }
    // return '$className($params)';
  }

  String get caseString {
    return '''case ${safeToString(ffRoute.name)}:

    return RouteResult(
      name: name,
      widget:  $constructor,
      ${ffRoute.showStatusBar != null ? 'showStatusBar: ${ffRoute.showStatusBar},' : ''}
      ${ffRoute.routeName != null ? 'routeName: ${safeToString(ffRoute.routeName)},' : ''}
      ${ffRoute.pageRouteType != null ? 'pageRouteType: ${ffRoute.pageRouteType},' : ''}
      ${ffRoute.description != null ? 'description: ${safeToString(ffRoute.description)},' : ''}
      ${ffRoute.exts != null ? 'exts:<String,dynamic>${json.encode(ffRoute.exts)},'.replaceAll('"', '\'') : ''});\n''';
  }

  @override
  String toString() {
    return 'RouteInfo {className: $className, ffRoute: $ffRoute}';
  }

  String getIsOptional(String name, FormalParameter parameter,
      ConstructorDeclaration rawConstructor) {
    String value = 'arguments[\'$name\']';

    final String type = getParameterType(name, parameter, rawConstructor);
    if (type != null) {
      value = '$value as $type';
    }

    if (parameter is DefaultFormalParameter && parameter.defaultValue != null) {
      value = '$value??${parameter.defaultValue}';
    }

    if (!parameter.isPositional) {
      value = '$name:' + value;
    }
    return value;
  }

  String getConstructorString(ConstructorDeclaration rawConstructor) {
    String constructorString = '';
    if (rawConstructor != null) {
      constructorString = getConstructor(rawConstructor);

      constructorString += '(';
      bool hasParameters = false;
      if (rawConstructor.parameters != null) {
        //final List<FormalParameter> optionals = <FormalParameter>[];

        for (final FormalParameter item
            in rawConstructor.parameters.parameters) {
          final String name = item.identifier?.toString();
          if (name != null) {
            hasParameters = true;
            if (item.isOptional) {
              constructorString += getIsOptional(name, item, rawConstructor);
              // if (!item.isRequired) {
              //   optionals.add(item);
              // }
            } else {
              constructorString += 'arguments[\'$name\']';
              final String type = getParameterType(name, item, rawConstructor);
              if (type != null) {
                constructorString += ' as $type';
              }
            }

            constructorString += ',';
          }
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
    return constructorString;
  }

  String getParameterType(String name, FormalParameter parameter,
      ConstructorDeclaration rawConstructor) {
    String typeString;
    if (parameter.toString().contains('this.')) {
      for (final FieldDeclaration item in fields) {
        if (item.fields.endToken.toString() == name) {
          final TypeAnnotation type = item.fields.type;
          typeString = type.toString();
          break;
        }
      }
    } else if (parameter is DefaultFormalParameter &&
        parameter.parameter is SimpleFormalParameter) {
      final TypeAnnotation type =
          (parameter.parameter as SimpleFormalParameter).type;
      typeString = type.toString();
    }
    typeString ??= parameter.beginToken?.toString();
    // if (ffRoute.argumentImports == null) {
    //   alertType(typeString);
    // }

    String display = typeString;
    if (!parameter.isOptional || parameter.toString().contains('required')) {
      display = '$display(required)';
    }

    constructorsMap[getConstructor(rawConstructor)] ??= <String>[];
    constructorsMap[getConstructor(rawConstructor)].add('$display $name');
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

    print(red.wrap(
        '''Error : '$typeString' must be imported. Please add argumentImports of FFRoute at $routePath.'''));
  }

  String getConstructor(ConstructorDeclaration rawConstructor) {
    String ctor = className;
    if (rawConstructor.name != null) {
      ctor += '.${rawConstructor.name.toString()}';
    }
    return ctor;
  }
}
