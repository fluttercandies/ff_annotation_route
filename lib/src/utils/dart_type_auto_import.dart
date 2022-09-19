// ignore_for_file: implementation_imports

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
//import 'package:analyzer/src/dart/constant/value.dart';
//import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:ff_annotation_route/src/utils/convert.dart';

class DartTypeAutoImport {
  DartTypeAutoImport(
    this.uri,
    this.dartType,
    this.prefix,
  );
  final String uri;
  final DartType dartType;
  final String prefix;

  String get import =>
      'import \'$uri\'${prefix.isNotEmpty ? ' as $prefix' : ''};';
}

class DartTypeAutoImportHelper {
  factory DartTypeAutoImportHelper() => _dartTypeAutoImportHelper;
  DartTypeAutoImportHelper._();
  static final DartTypeAutoImportHelper _dartTypeAutoImportHelper =
      DartTypeAutoImportHelper._();
  final Map<DartType, DartTypeAutoImport> _imports =
      <DartType, DartTypeAutoImport>{};

  void add(DartType type, String uri) {
    if (uri == 'dart:core') {
      return;
    }
    if (!_imports.containsKey(type)) {
      _imports[type] = DartTypeAutoImport(uri, type, 'autoimport' + uri.md5);

      print('automatically import for type($type): $uri');
    }
  }

  List<DartTypeAutoImport> getDartTypeAutoImports(InterfaceTypeImpl type) {
    final List<DartTypeAutoImport> imports = <DartTypeAutoImport>[];
    final DartTypeAutoImport? dartTypeAutoImport = _imports[type];
    if (dartTypeAutoImport != null) {
      imports.add(dartTypeAutoImport);
    }
    for (final DartType element in type.typeArguments) {
      imports.addAll(getDartTypeAutoImports(element as InterfaceTypeImpl));
    }

    return imports;
  }

  String fixDartTypeString(InterfaceTypeImpl type) {
    String input = type.getDisplayString(withNullability: true);
    final List<DartTypeAutoImport> imports = getDartTypeAutoImports(type);

    for (final DartTypeAutoImport import in imports) {
      final String dartTypeString =
          import.dartType.getDisplayString(withNullability: true);
      input =
          input.replaceAll(dartTypeString, '${import.prefix}.$dartTypeString');
    }
    return input;
  }

  String fixDefaultValueCodeString(
    String defaultValueCode,
    DartType dartType,
  ) {
    final List<DartTypeAutoImport> imports =
        getDartTypeAutoImports(dartType as InterfaceTypeImpl);

    for (final DartTypeAutoImport import in imports) {
      defaultValueCode = _getDefaultValueCodeString(defaultValueCode, import);
    }
    return defaultValueCode;
  }

  String _getDefaultValueCodeString(
    String defaultValueCode,
    DartTypeAutoImport dartTypeAutoImport,
  ) {
    final String prefix = dartTypeAutoImport.prefix;
    final String typeString =
        dartTypeAutoImport.dartType.getDisplayString(withNullability: false);
    // replace prefix
    if (defaultValueCode.contains('.')) {
      final int index = defaultValueCode.indexOf(typeString);
      if (index - 1 > 0 && defaultValueCode[index - 1] == '.') {
        final int end = index;
        int start = end - 1;
        for (; start > 0; start--) {
          if (defaultValueCode[start] == ' ') {
            start++;
            break;
          }
        }
        return defaultValueCode.replaceRange(
          start,
          end,
          '$prefix.',
        );
      }
    }

    return defaultValueCode.replaceAll(typeString, '$prefix.$typeString');
  }

  String getFormalParameters(List<ParameterElement> parameters) {
    // Assume the display string looks better wrapped when there are at least
    // three parameters. This avoids having to pre-compute the single-line
    // version and know the length of the function name/return type.
    final bool multiline = parameters.length >= 3;

    // The prefix for open groups is included in separator for single-line but
    // not for multline so must be added explicitly.
    final String openGroupPrefix = multiline ? ' ' : '';
    final String separator = multiline ? ',' : ', ';
    final String trailingComma = multiline ? ',\n' : '';
    final String parameterPrefix = multiline ? '\n  ' : '';
    final StringBuffer sb = StringBuffer();
    sb.write('(');

    _WriteFormalParameterKind? lastKind;
    String lastClose = '';

    void openGroup(_WriteFormalParameterKind kind, String open, String close) {
      if (lastKind != kind) {
        sb.write(lastClose);
        if (lastKind != null) {
          // We only need to include the space before the open group if there
          // was a previous parameter, otherwise it goes immediately after the
          // open paren.
          sb.write(openGroupPrefix);
        }
        sb.write(open);
        lastKind = kind;
        lastClose = close;
      }
    }

    for (int i = 0; i < parameters.length; i++) {
      if (i != 0) {
        sb.write(separator);
      }

      final ParameterElement parameter = parameters[i];
      if (parameter.isRequiredPositional) {
        openGroup(_WriteFormalParameterKind.requiredPositional, '', '');
      } else if (parameter.isOptionalPositional) {
        openGroup(_WriteFormalParameterKind.optionalPositional, '[', ']');
      } else if (parameter.isNamed) {
        openGroup(_WriteFormalParameterKind.named, '{', '}');
      }
      sb.write(parameterPrefix);
      _writeWithoutDelimiters(parameter, sb);
    }

    sb.write(trailingComma);
    sb.write(lastClose);
    sb.write(')');

    return sb.toString();
  }

  void _writeWithoutDelimiters(ParameterElement element, StringBuffer sb) {
    if (element.isRequiredNamed) {
      sb.write('required ');
    }

    sb.write(fixDartTypeString(element.type as InterfaceTypeImpl) +
        ' ' +
        element.displayName);

    String? defaultValueCode = element.defaultValueCode;
    if (defaultValueCode != null) {
      sb.write(' = ');

      defaultValueCode =
          fixDefaultValueCodeString(defaultValueCode, element.type);

      sb.write(defaultValueCode);
    }
  }

  Set<String> get imports =>
      _imports.values.map((DartTypeAutoImport e) => e.import).toSet();

  void findParametersImport(ClassElement classElement) {
    for (final ConstructorElement rawConstructor in classElement.constructors) {
      // ignore: prefer_foreach
      for (final ParameterElement parameter in rawConstructor.parameters) {
        DartTypeAutoImportHelper().findParameterImport(parameter);
      }
    }
  }

  void _findDartTypeImport(InterfaceTypeImpl type) {
    if (type.typeArguments.isEmpty) {
      final Uri uri = type.element2.source.uri;
      final Uri partParent = type.element2.library.source.uri;
      if (partParent != uri) {
        add(type, '$partParent');
      } else {
        add(type, '$uri');
      }
    } else {
      for (final DartType element in type.typeArguments) {
        if (element is InterfaceTypeImpl) {
          _findDartTypeImport(element);
        }
      }
    }
  }

  void findParameterImport(ParameterElement parameter) {
    if (parameter.type is InterfaceTypeImpl) {
      _findDartTypeImport(parameter.type as InterfaceTypeImpl);
    }
    //return;
    // refer
    // if (parameter.type is InterfaceTypeImpl) {
    //   _findDartTypeImport(parameter.type as InterfaceTypeImpl, parameter);
    // } else {
    //   // find import by Library
    //   final DartObjectImpl? dartOject =
    //       parameter.computeConstantValue() as DartObjectImpl?;
    //   _findParameterImport(
    //       dartOject?.variable?.library, parameter, parameter.type);
    // }
  }

  // void _findDartTypeImport(InterfaceTypeImpl type, ParameterElement parameter) {
  //   if (type.typeArguments.isEmpty) {
  //     _findParameterImport(type.element2.library, parameter, parameter.type);
  //   } else {
  //     for (final DartType element in type.typeArguments) {
  //       if (element is InterfaceTypeImpl) {
  //         _findParameterImport(element.element2.library, parameter, element);
  //       }
  //     }
  //   }
  // }

  // void _findParameterImport(
  //     LibraryElement? typeLibrary, ParameterElement parameter, DartType type) {
  //   if (typeLibrary != null) {
  //     final List<LibraryImportElement>? libraryImports =
  //         parameter.library?.libraryImports;
  //     bool find = false;
  //     if (libraryImports != null) {
  //       for (final LibraryImportElement importElement in libraryImports) {
  //         if (importElement.importedLibrary != null) {
  //           if (_containsImportLibrary(
  //               importElement.importedLibrary!, typeLibrary, type)) {
  //             final DirectiveUriWithLibraryImpl url =
  //                 importElement.uri as DirectiveUriWithLibraryImpl;

  //             if (url.relativeUriString == 'dart:core') {
  //               find = true;
  //               break;
  //             }
  //             add(type, '${url.source.uri}',
  //                 importElement.prefix?.element.name ?? '');
  //             find = true;
  //             break;
  //           }
  //         }
  //       }
  //     }

  //     if (!find) {
  //       add(type, '${typeLibrary.source.uri}', '');
  //     }
  //   }
  // }

  // bool _containsImportLibrary(
  //     LibraryElement parent, LibraryElement child, DartType type) {
  //   if (parent.source.uri == child.source.uri) {
  //     return true;
  //   }

  //   for (final LibraryExportElement exported in parent.libraryExports) {
  //     final DirectiveUriWithLibraryImpl uri =
  //         (exported as LibraryExportElementImpl).uri
  //             as DirectiveUriWithLibraryImpl;

  //     if (uri.source.uri == child.source.uri) {
  //       final String typeName = type.getDisplayString(withNullability: false);
  //       for (final NamespaceCombinator combinator in exported.combinators) {
  //         if (combinator is HideElementCombinator) {
  //           for (final String hideName in combinator.hiddenNames) {
  //             if (hideName == typeName) {
  //               return false;
  //             }
  //           }
  //         }

  //         if (combinator is ShowElementCombinator) {
  //           if (!combinator.shownNames.contains(typeName)) {
  //             return false;
  //           }
  //         }
  //       }
  //       return true;
  //     } else if (_containsImportLibrary(uri.library, child, type)) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }
}

enum _WriteFormalParameterKind { requiredPositional, optionalPositional, named }
