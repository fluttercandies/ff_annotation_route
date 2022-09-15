// ignore_for_file: implementation_imports

import 'package:analyzer/dart/element/element.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:analyzer/src/dart/constant/value.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'route_info_base.dart';

class RouteInfo extends RouteInfoBase {
  RouteInfo({
    required FFRoute ffRoute,
    required String className,
    required this.classElement,
  }) : super(
          className: className,
          ffRoute: ffRoute,
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
      final String defaultValueCode = _getDefaultValueCode(parameter);
      // int index = defaultValueCode
      //     .indexOf(parameter.type.getDisplayString(withNullability: false));

      // if (index > 0) {
      //   defaultValueCode = defaultValueCode.substring(index);
      // }

      value += ',$defaultValueCode';
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

  String _getDefaultValueCode(ParameterElement parameter) {
    String defaultValueCode = parameter.defaultValueCode!;

    // remove import as
    if (defaultValueCode.contains('.')) {
      final int index = defaultValueCode
          .indexOf(parameter.type.getDisplayString(withNullability: true));
      if (index - 1 > 0 && defaultValueCode[index - 1] == '.') {
        final int end = index;
        int start = end - 1;
        for (; start > 0; start--) {
          if (defaultValueCode[start] == ' ') {
            start++;
            break;
          }
        }
        defaultValueCode = defaultValueCode.replaceRange(start, end, '');
      }
    }
    return defaultValueCode;
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
    final DartObjectImpl? dartOject =
        parameter.computeConstantValue() as DartObjectImpl?;
    final Uri? uri = dartOject?.variable?.source?.uri;
    final Uri? librarySourceUri = dartOject?.variable?.librarySource?.uri;
    if (uri != null) {
      final Uri? importUri = uri != librarySourceUri ? librarySourceUri : uri;
      final String import = 'import \'$importUri\';';
      if (!ffRoute.argumentImports!.contains(import)) {
        print('automatically import for type(${parameter.type}): $import ');
        ffRoute.argumentImports!.add(import);
      }
    }
    /* else {
      final LibraryElement? libraryElement = dartOject?.variable?.library;

      final List<LibraryImportElement>? libraryImports =
          parameter.library?.libraryImports;
      if (libraryElement != null && libraryImports != null) {
        for (final LibraryImportElement importElement in libraryImports) {
          if (importElement.importedLibrary != null) {
            if (findddd(importElement.importedLibrary!, libraryElement)) {
              addImport(importElement, showCombinator: false);
              break;
            }
          }
        }
      }
    } */

    final String typeString = parameter.type.toString();
    return typeString;
  }

  bool findddd(LibraryElement parent, LibraryElement child) {
    if (parent.source.uri == child.source.uri) {
      return true;
    }

    for (final LibraryExportElement exported in parent.libraryExports) {
      final DirectiveUriWithLibraryImpl uri =
          (exported as LibraryExportElementImpl).uri
              as DirectiveUriWithLibraryImpl;
      if (uri.relativeUri == child.source.uri) {
        return true;
      } else {
        return findddd(uri.library, child);
      }
    }

    return false;
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
        String args = rawConstructor
            .toString()
            .substring(rawConstructor.toString().indexOf('('))
            .trim();
        for (final ParameterElement parameter in rawConstructor.parameters) {
          if (parameter.defaultValueCode != null) {
            final String code = _getDefaultValueCode(parameter);
            if (code != parameter.defaultValueCode) {
              args = args.replaceAll(parameter.defaultValueCode!, code);
            }
          }
        }

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
