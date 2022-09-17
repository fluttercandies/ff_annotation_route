// ignore_for_file: implementation_imports

import 'package:analyzer/dart/element/element.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route/src/file_info.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:analyzer/src/dart/constant/value.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'route_info_base.dart';

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
      //final String defaultValueCode = _getDefaultValueCode(parameter);
      // int index = defaultValueCode
      //     .indexOf(parameter.type.getDisplayString(withNullability: false));

      // if (index > 0) {
      //   defaultValueCode = defaultValueCode.substring(index);
      // }

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

  // String _getDefaultValueCode(ParameterElement parameter) {
  //   String defaultValueCode = parameter.defaultValueCode!;

  //   // remove import as
  //   if (defaultValueCode.contains('.')) {
  //     final int index = defaultValueCode
  //         .indexOf(parameter.type.getDisplayString(withNullability: true));
  //     if (index - 1 > 0 && defaultValueCode[index - 1] == '.') {
  //       final int end = index;
  //       int start = end - 1;
  //       for (; start > 0; start--) {
  //         if (defaultValueCode[start] == ' ') {
  //           start++;
  //           break;
  //         }
  //       }
  //       defaultValueCode = defaultValueCode.replaceRange(start, end, '');
  //     }
  //   }
  //   return defaultValueCode;
  // }

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
    // already add import and has prefix
    if (fileInfo.typeImportPrefixMap.containsKey(parameter.type)) {
      return fileInfo.getTypeString(parameter.type);
    }

    // find import by import prefix with defaultValueCode/field
    final String? prefix =
        fileInfo.parameterHasPrefixImport(parameter, classElement);
    if (prefix != null) {
      addImport(
        fileInfo.importPrefixMap[prefix]!,
        type: parameter.type,
      );
      fileInfo.typeImportPrefixMap[parameter.type] = prefix;
      return fileInfo.getTypeString(parameter.type);
    }

    LibraryElement? typeLibrary;
    // refer
    if (parameter.type is InterfaceTypeImpl) {
      typeLibrary = (parameter.type as InterfaceTypeImpl).element2.library;
    } else {
      // find import by Library
      final DartObjectImpl? dartOject =
          parameter.computeConstantValue() as DartObjectImpl?;
      typeLibrary = dartOject?.variable?.library;
    }

    if (typeLibrary != null) {
      final List<LibraryImportElement>? libraryImports =
          parameter.library?.libraryImports;
      if (libraryImports != null) {
        for (final LibraryImportElement importElement in libraryImports) {
          if (importElement.importedLibrary != null) {
            if (_containsImportLibrary(
                importElement.importedLibrary!, typeLibrary)) {
              addImport(
                importElement,
                containsCombinator: true,
                type: parameter.type,
              );
              if (importElement.prefix != null) {
                fileInfo.typeImportPrefixMap[parameter.type] =
                    importElement.prefix!.element.name;
              }
              return fileInfo.getTypeString(parameter.type);
            }
          }
        }
      }

      final String import = 'import \'${typeLibrary.source.uri}\';';

      FileInfo.imports.add(import);
    }

    return parameter.type.toString();
  }

  bool _containsImportLibrary(LibraryElement parent, LibraryElement child) {
    if (parent.source.uri == child.source.uri) {
      return true;
    }

    for (final LibraryExportElement exported in parent.libraryExports) {
      final DirectiveUriWithLibraryImpl uri =
          (exported as LibraryExportElementImpl).uri
              as DirectiveUriWithLibraryImpl;
      if (uri.source.uri == child.source.uri) {
        return true;
      } else if (_containsImportLibrary(uri.library, child)) {
        return true;
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
          final String type = '${parameter.type} ${parameter.displayName}';
          // add prefix if has
          args = args.replaceAll(type,
              '${fileInfo.getTypeString(parameter.type)} ${parameter.displayName}');
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
