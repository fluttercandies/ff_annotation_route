// ignore_for_file: implementation_imports, prefer_final_locals, always_specify_types, always_put_control_body_on_new_line, prefer_final_in_for_each, prefer_foreach

import 'package:_fe_analyzer_shared/src/type_inference/type_analyzer_operations.dart'
    show Variance;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' as at;
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/display_string_builder.dart';
import 'package:analyzer/src/dart/element/type_algebra.dart';

import 'dart_type_auto_import.dart';

class MyElementDisplayStringBuilder extends ElementDisplayStringBuilder {
  MyElementDisplayStringBuilder({
    super.withNullability = true,
    super.multiline = false,
    super.preferTypeAlias = true,
  })  : _withNullability = withNullability,
        _multiline = multiline;

  final bool _withNullability;
  final bool _multiline;
  final StringBuffer _buffer = StringBuffer();

  @override
  String toString() {
    return _buffer.toString();
  }

  @override
  void writeAbstractElement(ElementImpl element) {
    _write(element.name ?? '<unnamed $runtimeType>');
  }

  @override
  void writeClassElement(ClassElementImpl element) {
    if (element.isAbstract) {
      _write('abstract ');
    }

    _write('class ');
    _write(element.displayName);

    _writeTypeParameters(element.typeParameters);

    _writeTypeIfNotObject(' extends ', element.supertype);
    _writeTypesIfNotEmpty(' with ', element.mixins);
    _writeTypesIfNotEmpty(' implements ', element.interfaces);
  }

  @override
  void writeCompilationUnitElement(CompilationUnitElementImpl element) {
    var path = element.source.fullName;
    _write(path);
  }

  @override
  void writeConstructorElement(ConstructorElement element) {
    _writeType(element.returnType);
    _write(' ');

    _write(element.displayName);

    _writeFormalParameters(
      element.parameters,
      forElement: true,
      allowMultiline: true,
    );
  }

  @override
  void writeDynamicType() {
    _write('dynamic');
  }

  @override
  void writeEnumElement(EnumElement element) {
    _write('enum ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _writeTypesIfNotEmpty(' with ', element.mixins);
    _writeTypesIfNotEmpty(' implements ', element.interfaces);
  }

  @override
  void writeExecutableElement(ExecutableElement element, String name) {
    _writeType(element.returnType);
    _write(' ');

    _write(name);

    if (element.kind != ElementKind.GETTER) {
      _writeTypeParameters(element.typeParameters);
      _writeFormalParameters(
        element.parameters,
        forElement: true,
        allowMultiline: true,
      );
    }
  }

  @override
  void writeExportElement(LibraryExportElementImpl element) {
    _write('export ');
    _writeDirectiveUri(element.uri);
  }

  @override
  void writeExtensionElement(ExtensionElement element) {
    _write('extension ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _write(' on ');
    _writeType(element.extendedType);
  }

  @override
  void writeFormalParameter(ParameterElement element) {
    if (element.isRequiredPositional) {
      _writeWithoutDelimiters(element, forElement: true);
    } else if (element.isOptionalPositional) {
      _write('[');
      _writeWithoutDelimiters(element, forElement: true);
      _write(']');
    } else if (element.isNamed) {
      _write('{');
      _writeWithoutDelimiters(element, forElement: true);
      _write('}');
    }
  }

  @override
  void writeFunctionType(at.FunctionType type) {
    // zmtzawqlp
    if (type.alias != null) {
      final DartTypeAutoImport? dartTypeAutoImport =
          DartTypeAutoImportHelper().getImport(type);
      if (dartTypeAutoImport != null) {
        _write(
            '${dartTypeAutoImport.prefix}.${type.alias!.element.displayName}');
        return;
      }
    }

    type = _uniqueTypeParameters(type);

    _writeType(type.returnType);
    _write(' Function');
    _writeTypeParameters(type.typeFormals);
    _writeFormalParameters(type.parameters, forElement: false);
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeGenericFunctionTypeElement(GenericFunctionTypeElementImpl element) {
    _writeType(element.returnType);
    _write(' Function');
    _writeTypeParameters(element.typeParameters);
    _writeFormalParameters(element.parameters, forElement: true);
  }

  @override
  void writeImportElement(LibraryImportElementImpl element) {
    _write('import ');
    _writeDirectiveUri(element.uri);
  }

  @override
  void writeInterfaceType(at.InterfaceType type) {
    // zmtzawqlp
    final DartTypeAutoImport? dartTypeAutoImport =
        DartTypeAutoImportHelper().getImport(type);
    if (dartTypeAutoImport != null) {
      if (type.alias != null) {
        _write(
            '${dartTypeAutoImport.prefix}.${type.alias!.element.displayName}');
      } else {
        _write('${dartTypeAutoImport.prefix}.${type.element.name}');
      }
    } else {
      _write(type.element.name);
    }

    _writeTypeArguments(type.typeArguments);
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeMixinElement(MixinElementImpl element) {
    _write('mixin ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _writeTypesIfNotEmpty(' on ', element.superclassConstraints);
    _writeTypesIfNotEmpty(' implements ', element.interfaces);
  }

  @override
  void writeNeverType(at.NeverType type) {
    _write('Never');
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writePartElement(PartElementImpl element) {
    _write('part ');
    _writeDirectiveUri(element.uri);
  }

  @override
  void writePrefixElement(PrefixElementImpl element) {
    _write('as ');
    _write(element.displayName);
  }

  @override
  void writeRecordType(at.RecordType type) {
    final positionalFields = type.positionalFields;
    final namedFields = type.namedFields;
    final fieldCount = positionalFields.length + namedFields.length;
    _write('(');

    var index = 0;
    for (final field in positionalFields) {
      _writeType(field.type);
      if (index++ < fieldCount - 1) {
        _write(', ');
      }
    }

    if (namedFields.isNotEmpty) {
      _write('{');
      for (final field in namedFields) {
        _writeType(field.type);
        _write(' ');
        _write(field.name);
        if (index++ < fieldCount - 1) {
          _write(', ');
        }
      }
      _write('}');
    }

    _write(')');
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeTypeAliasElement(TypeAliasElementImpl element) {
    _write('typedef ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _write(' = ');

    ElementImpl? aliasedElement = element.aliasedElement;
    if (aliasedElement != null) {
      aliasedElement.appendTo(this);
    } else {
      _writeType(element.aliasedType);
    }
  }

  @override
  void writeTypeParameter(TypeParameterElement element) {
    if (element is TypeParameterElementImpl) {
      var variance = element.variance;
      if (!element.isLegacyCovariant && variance != Variance.unrelated) {
        _write(variance.keyword);
        _write(' ');
      }
    }

    _write(element.displayName);

    var bound = element.bound;
    if (bound != null) {
      _write(' extends ');
      _writeType(bound);
    }
  }

  @override
  void writeTypeParameterType(TypeParameterTypeImpl type) {
    final promotedBound = type.promotedBound;
    if (promotedBound != null) {
      final hasSuffix = type.nullabilitySuffix != NullabilitySuffix.none;
      if (hasSuffix) {
        _write('(');
      }
      _write(type.element.displayName);
      _write(' & ');
      _writeType(promotedBound);
      if (hasSuffix) {
        _write(')');
      }
    } else {
      _write(type.element.displayName);
    }
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeUnknownInferredType() {
    _write('_');
  }

  @override
  void writeVariableElement(VariableElement element) {
    _writeType(element.type);
    _write(' ');
    _write(element.displayName);
  }

  @override
  void writeVoidType() {
    _write('void');
  }

  void _write(String str) {
    _buffer.write(str);
  }

  void _writeDirectiveUri(DirectiveUri uri) {
    if (uri is DirectiveUriWithUnitImpl) {
      _write('unit ${uri.unit.source.uri}');
    } else if (uri is DirectiveUriWithSourceImpl) {
      _write('source ${uri.source}');
    } else {
      _write('<unknown>');
    }
  }

  void _writeFormalParameters(
    List<ParameterElement> parameters, {
    required bool forElement,
    bool allowMultiline = false,
  }) {
    // Assume the display string looks better wrapped when there are at least
    // three parameters. This avoids having to pre-compute the single-line
    // version and know the length of the function name/return type.
    var multiline = allowMultiline && _multiline && parameters.length >= 3;

    // The prefix for open groups is included in separator for single-line but
    // not for multline so must be added explicitly.
    var openGroupPrefix = multiline ? ' ' : '';
    var separator = multiline ? ',' : ', ';
    var trailingComma = multiline ? ',\n' : '';
    var parameterPrefix = multiline ? '\n  ' : '';

    _write('(');

    _WriteFormalParameterKind? lastKind;
    var lastClose = '';

    void openGroup(_WriteFormalParameterKind kind, String open, String close) {
      if (lastKind != kind) {
        _write(lastClose);
        if (lastKind != null) {
          // We only need to include the space before the open group if there
          // was a previous parameter, otherwise it goes immediately after the
          // open paren.
          _write(openGroupPrefix);
        }
        _write(open);
        lastKind = kind;
        lastClose = close;
      }
    }

    for (var i = 0; i < parameters.length; i++) {
      if (i != 0) {
        _write(separator);
      }

      var parameter = parameters[i];
      if (parameter.isRequiredPositional) {
        openGroup(_WriteFormalParameterKind.requiredPositional, '', '');
      } else if (parameter.isOptionalPositional) {
        openGroup(_WriteFormalParameterKind.optionalPositional, '[', ']');
      } else if (parameter.isNamed) {
        openGroup(_WriteFormalParameterKind.named, '{', '}');
      }
      _write(parameterPrefix);
      _writeWithoutDelimiters(parameter, forElement: forElement);
    }

    _write(trailingComma);
    _write(lastClose);
    _write(')');
  }

  void _writeNullability(NullabilitySuffix nullabilitySuffix) {
    if (_withNullability) {
      switch (nullabilitySuffix) {
        case NullabilitySuffix.question:
          _write('?');
          break;
        case NullabilitySuffix.star:
          _write('*');
          break;
        case NullabilitySuffix.none:
          break;
      }
    }
  }

  void _writeType(at.DartType type) {
    (type as TypeImpl).appendTo(this);
  }

  void _writeTypeArguments(List<at.DartType> typeArguments) {
    if (typeArguments.isEmpty) {
      return;
    }

    _write('<');
    for (var i = 0; i < typeArguments.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      (typeArguments[i] as TypeImpl).appendTo(this);
    }
    _write('>');
  }

  void _writeTypeIfNotObject(String prefix, at.DartType? type) {
    if (type != null && !type.isDartCoreObject) {
      _write(prefix);
      _writeType(type);
    }
  }

  void _writeTypeParameters(List<TypeParameterElement> elements) {
    if (elements.isEmpty) return;

    _write('<');
    for (var i = 0; i < elements.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      (elements[i] as TypeParameterElementImpl).appendTo(this);
    }
    _write('>');
  }

  void _writeTypes(List<at.DartType> types) {
    for (var i = 0; i < types.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      _writeType(types[i]);
    }
  }

  void _writeTypesIfNotEmpty(String prefix, List<at.DartType> types) {
    if (types.isNotEmpty) {
      _write(prefix);
      _writeTypes(types);
    }
  }

  void _writeWithoutDelimiters(
    ParameterElement element, {
    required bool forElement,
  }) {
    if (element.isRequiredNamed) {
      _write('required ');
    }

    _writeType(element.type);

    if (forElement || element.isNamed) {
      _write(' ');
      _write(element.displayName);
    }

    if (forElement) {
      var defaultValueCode = element.defaultValueCode;
      if (defaultValueCode != null) {
        _write(' = ');
        _write(defaultValueCode);
      }
    }
  }

  static at.FunctionType _uniqueTypeParameters(at.FunctionType type) {
    if (type.typeFormals.isEmpty) {
      return type;
    }

    var referencedTypeParameters = <TypeParameterElement>{};

    void collectTypeParameters(at.DartType? type) {
      if (type is at.TypeParameterType) {
        referencedTypeParameters.add(type.element);
      } else if (type is at.FunctionType) {
        for (var typeParameter in type.typeFormals) {
          collectTypeParameters(typeParameter.bound);
        }
        for (var parameter in type.parameters) {
          collectTypeParameters(parameter.type);
        }
        collectTypeParameters(type.returnType);
      } else if (type is at.InterfaceType) {
        for (var typeArgument in type.typeArguments) {
          collectTypeParameters(typeArgument);
        }
      }
    }

    collectTypeParameters(type);
    referencedTypeParameters.removeAll(type.typeFormals);

    var namesToAvoid = <String>{};
    for (var typeParameter in referencedTypeParameters) {
      namesToAvoid.add(typeParameter.displayName);
    }

    var newTypeParameters = <TypeParameterElement>[];
    for (var typeParameter in type.typeFormals) {
      var name = typeParameter.name;
      for (var counter = 0; !namesToAvoid.add(name); counter++) {
        const unicodeSubscriptZero = 0x2080;
        const unicodeZero = 0x30;

        var subscript = String.fromCharCodes('$counter'.codeUnits.map((n) {
          return unicodeSubscriptZero + (n - unicodeZero);
        }));

        name = typeParameter.name + subscript;
      }

      var newTypeParameter = TypeParameterElementImpl(name, -1);
      newTypeParameter.bound = typeParameter.bound;
      newTypeParameters.add(newTypeParameter);
    }

    return replaceTypeParameters(type as FunctionTypeImpl, newTypeParameters);
  }
}

enum _WriteFormalParameterKind { requiredPositional, optionalPositional, named }
