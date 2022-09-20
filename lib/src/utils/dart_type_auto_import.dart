// ignore_for_file: implementation_imports

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
//import 'package:analyzer/src/dart/constant/value.dart';
//import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:ff_annotation_route/src/utils/convert.dart';
import 'package:io/ansi.dart';

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

  List<DartTypeAutoImport> getDartTypeAutoImports(DartType dartType) {
    final List<DartTypeAutoImport> imports = <DartTypeAutoImport>[];
    final DartTypeAutoImport? dartTypeAutoImport = _imports[dartType];
    if (dartTypeAutoImport != null) {
      imports.add(dartTypeAutoImport);
    }

    if (dartType is InterfaceTypeImpl) {
      for (final DartType element in dartType.typeArguments) {
        imports.addAll(getDartTypeAutoImports(element));
      }
    } else if (dartType is FunctionTypeImpl) {
      for (final ParameterElement element in dartType.parameters) {
        imports.addAll(getDartTypeAutoImports(element.type));
      }
      imports.addAll(getDartTypeAutoImports(dartType.returnType));
    } else if (dartType is VoidTypeImpl) {
      // do nothing
    }

    return imports;
  }

  String fixDartTypeString(DartType type) {
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
    for (final DartTypeAutoImport import in getDartTypeAutoImports(dartType)) {
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

    sb.write(fixDartTypeString(element.type) + ' ' + element.displayName);

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
        DartTypeAutoImportHelper().findParameterImport(parameter.type);
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
      // ignore: prefer_foreach
      for (final DartType element in type.typeArguments) {
        findParameterImport(element);
      }
    }
  }

  void findParameterImport(DartType dartType) {
    if (dartType is InterfaceTypeImpl) {
      _findDartTypeImport(dartType);
    } else if (dartType is FunctionTypeImpl) {
      // ignore: prefer_foreach
      for (final ParameterElement element in dartType.parameters) {
        findParameterImport(element.type);
      }
      findParameterImport(dartType.returnType);
    } else if (dartType is VoidTypeImpl) {
      // do nothing
    } else {
      // TODO(zmtzawqlp): not support now
      print(red.wrap(
          'This parameter type is not support now: ${dartType.runtimeType}.'));
    }
  }
}

enum _WriteFormalParameterKind { requiredPositional, optionalPositional, named }
