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
  );
  final String uri;
  final DartType dartType;
  String prefix = '';

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

  void add(DartType type, String uri, String prefix) {
    if (!_imports.containsKey(type)) {
      if (prefix.isEmpty &&
          !uri.startsWith('package:flutter') &&
          !uri.startsWith('dart:')) {
        prefix = 'autoimport' + '$uri$type'.md5;
      }

      final List<DartType> sameTypeList = _imports.keys
          .where((DartType element) =>
              element != type && element.toString() == type.toString())
          .toList();
      final DartTypeAutoImport dartTypeAutoImport =
          DartTypeAutoImport(uri, type)..prefix = prefix;
      _imports[type] = dartTypeAutoImport;
      if (sameTypeList.isNotEmpty) {
        sameTypeList.add(type);
        for (final DartType type in sameTypeList) {
          final DartTypeAutoImport dartTypeAutoImport = _imports[type]!;
          dartTypeAutoImport.prefix =
              'autoimport' + '${dartTypeAutoImport.uri}$type'.md5;
        }
      }

      print('automatically import for type($type): ${dartTypeAutoImport.uri} ');
    }
  }

  String getTypeString(InterfaceTypeImpl type, {bool withNullability = true}) {
    final DartTypeAutoImport? dartTypeAutoImport = getDartTypeAutoImport(type);

    if (dartTypeAutoImport != null && dartTypeAutoImport.prefix.isNotEmpty) {
      final String typeString =
          type.getDisplayString(withNullability: withNullability);
      final String typeImportString = dartTypeAutoImport.dartType
          .getDisplayString(withNullability: withNullability);
      return typeString.replaceAll(
          typeImportString, '${dartTypeAutoImport.prefix}.$typeImportString');
    }

    return '$type';
  }

  DartTypeAutoImport? getDartTypeAutoImport(InterfaceTypeImpl type) {
    DartTypeAutoImport? dartTypeAutoImport = _imports[type];
    if (dartTypeAutoImport != null) {
      return dartTypeAutoImport;
    }

    for (final DartType element in type.typeArguments) {
      dartTypeAutoImport = getDartTypeAutoImport(element as InterfaceTypeImpl);
      if (dartTypeAutoImport != null) {
        return dartTypeAutoImport;
      }
    }
    return null;
  }

  String getTypePrefix(InterfaceTypeImpl type) {
    final DartTypeAutoImport? dartTypeAutoImport = _imports[type];
    if (dartTypeAutoImport != null && dartTypeAutoImport.prefix.isNotEmpty) {
      return dartTypeAutoImport.prefix;
    }

    for (final DartType element in type.typeArguments) {
      final String prefix = getTypePrefix(element as InterfaceTypeImpl);
      if (prefix.isNotEmpty) {
        return prefix;
      }
    }
    return '';
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

    sb.write(getTypeString(element.type as InterfaceTypeImpl) +
        ' ' +
        element.displayName);

    String? defaultValueCode = element.defaultValueCode;
    if (defaultValueCode != null) {
      sb.write(' = ');

      defaultValueCode =
          getDefaultValueCodeString(defaultValueCode, element.type);

      sb.write(defaultValueCode);
    }
  }

  String getDefaultValueCodeString(
    String defaultValueCode,
    DartType dartType,
  ) {
    if (defaultValueCode.contains('ExtendedImageMode')) {
      print('ddd');
    }
    final DartTypeAutoImport? dartTypeAutoImport =
        getDartTypeAutoImport(dartType as InterfaceTypeImpl);
    final String? prefix = dartTypeAutoImport?.prefix;
    // replace prefix
    if (defaultValueCode.contains('.')) {
      final int index = defaultValueCode.indexOf(
          (dartTypeAutoImport?.dartType ?? dartType)
              .getDisplayString(withNullability: false));
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
          prefix != null && prefix.isNotEmpty ? '$prefix.' : '',
        );
      }
    }

    if (prefix != null && prefix.isNotEmpty) {
      final String type = (dartTypeAutoImport?.dartType ?? dartType)
          .getDisplayString(withNullability: false);
      return defaultValueCode.replaceAll(type, '$prefix.$type');
    }
    return defaultValueCode;
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

  void _findDartTypeImport1(InterfaceTypeImpl type) {
    if (type.typeArguments.isEmpty) {
      final Uri uri = type.element2.source.uri;
      final Uri sss = type.element2.library.source.uri;
      if (sss != uri) {
        add(type, '$sss', '');
      } else {
        add(type, '$uri', '');
      }
    } else {
      for (final DartType element in type.typeArguments) {
        if (element is InterfaceTypeImpl) {
          _findDartTypeImport1(element);
        }
      }
    }
  }

  void findParameterImport(ParameterElement parameter) {
    if (parameter.type is InterfaceTypeImpl) {
      _findDartTypeImport1(parameter.type as InterfaceTypeImpl);
    }
    return;
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
