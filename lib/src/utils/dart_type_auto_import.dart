import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' as at;
import 'package:analyzer/src/dart/ast/to_source_visitor.dart';
//import 'package:analyzer/src/dart/constant/value.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:io/ansi.dart';
import 'package:meta/meta.dart';

import 'convert.dart';
import 'display_string_builder.dart';
import 'git_package_handler.dart';

class DartTypeAutoImport {
  const DartTypeAutoImport(
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
  final _imports = <DartType, DartTypeAutoImport>{};

  void add(at.DartType type, String uri) {
    if (uri == 'dart:core') {
      return;
    }

    final dartType = DartType(type, type.alias);

    if (!_imports.containsKey(dartType)) {
      _imports[dartType] = DartTypeAutoImport(
        uri,
        dartType,
        'autoimport${uri.md5}',
      );

      print('automatically import for type($type): $uri');
    }
  }

  DartTypeAutoImport? getImport(at.DartType type) {
    final dartTypeAutoImport = _imports[DartType(type, type.alias)];
    if (dartTypeAutoImport != null &&
        type.alias == dartTypeAutoImport.dartType.alias) {
      return dartTypeAutoImport;
    }
    return null;
  }

  List<DartTypeAutoImport> getDartTypeAutoImports(at.DartType dartType) {
    final List<DartTypeAutoImport> imports = <DartTypeAutoImport>[];
    final DartTypeAutoImport? dartTypeAutoImport = getImport(dartType);
    if (dartTypeAutoImport != null) {
      imports.add(dartTypeAutoImport);
    }

    if (dartType is InterfaceTypeImpl) {
      for (final at.DartType element in dartType.typeArguments) {
        imports.addAll(getDartTypeAutoImports(element));
      }
    } else if (dartType is FunctionTypeImpl) {
      imports.addAll(getDartTypeAutoImports(dartType.returnType));
      for (final ParameterElement element in dartType.parameters) {
        imports.addAll(getDartTypeAutoImports(element.type));
      }
    } else if (dartType is VoidTypeImpl || dartType is DynamicTypeImpl) {
      // do nothing
    }

    return imports;
  }

  String fixDartTypeString(at.DartType type) {
    if (type is InterfaceTypeImpl) {
      final MyElementDisplayStringBuilder builder =
          MyElementDisplayStringBuilder(
        withNullability: true,
        preferTypeAlias: true,
      );
      builder.writeInterfaceType(type);
      return builder.toString();
    } else if (type is FunctionTypeImpl) {
      final MyElementDisplayStringBuilder builder =
          MyElementDisplayStringBuilder(
        withNullability: true,
        preferTypeAlias: true,
      );
      builder.writeFunctionType(type);
      return builder.toString();
    }

    String input = type.getDisplayString(withNullability: true);
    final List<DartTypeAutoImport> imports = getDartTypeAutoImports(type);

    for (final DartTypeAutoImport import in imports) {
      final String dartTypeString =
          import.dartType.dartType.getDisplayString(withNullability: true);

      String prefixType = '${import.prefix}.$dartTypeString';
      if (import.dartType.alias != null) {
        prefixType =
            '${import.prefix}.${import.dartType.alias!.element.displayName}';
      }
      input = input.replaceFirst(dartTypeString, prefixType);
    }
    return input;
  }

  String? getDefaultValueString(
    ParameterElement parameter,
    List<String> prefixes,
  ) {
    String? defaultValueCode;
    // remove default prefix if has
    if (parameter.hasDefaultValue &&
        parameter is ConstVariableElement &&
        (parameter as ConstVariableElement).constantInitializer != null) {
      final StringBuffer sb = StringBuffer();
      (parameter as ConstVariableElement).constantInitializer!.accept<void>(
            MyToSourceVisitor(
              sink: sb,
              prefixes: prefixes,
            ),
          );
      defaultValueCode = sb.toString();
    }
    // add auto import prefix
    if (defaultValueCode != null) {
      for (final DartTypeAutoImport import
          in getDartTypeAutoImports(parameter.type)) {
        defaultValueCode =
            _getDefaultValueCodeString(defaultValueCode!, import);
      }
    }

    return defaultValueCode ?? parameter.defaultValueCode;
  }

  String _getDefaultValueCodeString(
    String defaultValueCode,
    DartTypeAutoImport dartTypeAutoImport,
  ) {
    final String prefix = dartTypeAutoImport.prefix;
    final String typeString = dartTypeAutoImport.dartType.dartType
        .getDisplayString(withNullability: false);
    // replace prefix
    // if (defaultValueCode.contains('.')) {
    //   final int index = defaultValueCode.indexOf(typeString);
    //   if (index - 1 > 0 && defaultValueCode[index - 1] == '.') {
    //     final int end = index;
    //     int start = end - 1;
    //     for (; start > 0; start--) {
    //       if (defaultValueCode[start] == ' ') {
    //         start++;
    //         break;
    //       }
    //     }
    //     return defaultValueCode.replaceRange(
    //       start,
    //       end,
    //       '$prefix.',
    //     );
    //   }
    // }

    return defaultValueCode.replaceAll(typeString, '$prefix.$typeString');
  }

  String getFormalParameters(
    List<ParameterElement> parameters,
    List<String> prefixs,
  ) {
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
      _writeWithoutDelimiters(
        parameter,
        sb,
        prefixs,
      );
    }

    sb.write(trailingComma);
    sb.write(lastClose);
    sb.write(')');

    return sb.toString();
  }

  void _writeWithoutDelimiters(
    ParameterElement element,
    StringBuffer sb,
    List<String> prefixs,
  ) {
    if (element.isRequiredNamed) {
      sb.write('required ');
    }

    sb.write('${fixDartTypeString(element.type)} ${element.displayName}');

    final defaultValueCode = DartTypeAutoImportHelper().getDefaultValueString(
      element,
      prefixs,
    );
    if (defaultValueCode != null) {
      sb.write(' = ');

      sb.write(defaultValueCode);
    }
  }

  Set<String> get imports =>
      _imports.values.map((DartTypeAutoImport e) => e.import).toSet();

  void findParametersImport(ClassElement classElement) {
    for (final ConstructorElement rawConstructor in classElement.constructors) {
      for (final ParameterElement parameter in rawConstructor.parameters) {
        DartTypeAutoImportHelper().findParameterImport(parameter.type);
      }
    }
  }

  void _findDartTypeImport(InterfaceTypeImpl type) {
    if (type.typeArguments.isEmpty) {
      Uri uri = type.element.source.uri;
      final Uri partParent = type.element.library.source.uri;
      if (partParent != uri) {
        uri = partParent;
      }
      add(type, GitPackageHandler().replaceUri('$uri'));
    } else {
      for (final at.DartType element in type.typeArguments) {
        findParameterImport(element);
      }
    }
  }

  void findParameterImport(at.DartType dartType) {
    if (dartType.alias != null) {
      final aliasElement = dartType.alias!;
      Uri uri = aliasElement.element.source.uri;
      final Uri partParent = aliasElement.element.library.source.uri;
      if (partParent != uri) {
        uri = partParent;
      }
      add(dartType, GitPackageHandler().replaceUri('$uri'));
    } else if (dartType is InterfaceTypeImpl) {
      _findDartTypeImport(dartType);
    } else if (dartType is FunctionTypeImpl) {
      findParameterImport(dartType.returnType);
      for (final ParameterElement element in dartType.parameters) {
        findParameterImport(element.type);
      }
    } else if (dartType is VoidTypeImpl || dartType is DynamicTypeImpl) {
      // do nothing
    } else {
      // TODO(zmtzawqlp): not support now
      print(
        red.wrap(
          'This parameter type is not support now: ${dartType.runtimeType}.',
        ),
      );
    }
  }
}

enum _WriteFormalParameterKind { requiredPositional, optionalPositional, named }

@immutable
class DartType {
  const DartType(this.dartType, this.alias);

  final at.DartType dartType;
  final at.InstantiatedTypeAliasElement? alias;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartType &&
          runtimeType == other.runtimeType &&
          dartType == other.dartType &&
          alias == other.alias;

  @override
  int get hashCode => Object.hash(dartType, alias);
}

class MyToSourceVisitor extends ToSourceVisitor {
  MyToSourceVisitor({
    required StringSink sink,
    required this.prefixes,
  }) : super(sink);

  final List<String> prefixes;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    // remove default prefix
    if (!prefixes.contains(node.prefix.name)) {
      _visitNode(node.prefix);
      sink.write('.');
    }

    _visitNode(node.identifier);
  }

  @override
  void visitImportPrefixReference(ImportPrefixReference node) {
    // remove default prefix
    if (!prefixes.contains(node.name.lexeme)) {
      sink.write(node.name.lexeme);
      sink.write('.');
    }
  }

  /// Print the given [node], printing the [prefix] before the node,
  /// and [suffix] after the node, if it is non-`null`.
  void _visitNode(AstNode? node, {String prefix = '', String suffix = ''}) {
    if (node != null) {
      sink.write(prefix);
      node.accept(this);
      sink.write(suffix);
    }
  }
}
