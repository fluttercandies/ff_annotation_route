import 'package:_fe_analyzer_shared/src/type_inference/type_analyzer_operations.dart'
    show Variance;
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/display_string_builder.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_algebra.dart';
import 'package:analyzer/src/utilities/extensions/element.dart';

import 'dart_type_auto_import.dart' hide DartType;

/// A class that builds a "display string" for [Element]s and [DartType]s.
class MyElementDisplayStringBuilder extends ElementDisplayStringBuilder {
  MyElementDisplayStringBuilder({
    @Deprecated('Only non-nullable by default mode is supported')
    super.withNullability,
    super.multiline,
    required super.preferTypeAlias,
  })  : _withNullability = withNullability,
        _multiline = multiline;

  /// Whether to include the nullability ('?' characters) in a display string.
  final bool _withNullability;

  /// Whether to allow a display string to be written in multiple lines.
  final bool _multiline;

  final StringBuffer _buffer = StringBuffer();

  @override
  String toString() => _buffer.toString();

  @override
  void writeAbstractElement(ElementImpl element) {
    _write(element.name ?? '<unnamed $runtimeType>');
  }

  @override
  void writeAbstractElement2(ElementImpl2 element) {
    _write(element.name3 ?? '<unnamed $runtimeType>');
  }

  @override
  void writeClassElement(ClassElementImpl element) {
    if (element.isAugmentation) {
      _write('augment ');
    }

    if (element.isSealed) {
      _write('sealed ');
    } else if (element.isAbstract) {
      _write('abstract ');
    }
    if (element.isBase) {
      _write('base ');
    } else if (element.isInterface) {
      _write('interface ');
    } else if (element.isFinal) {
      _write('final ');
    }
    if (element.isMixinClass) {
      _write('mixin ');
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
  void writeConstructorElement(ConstructorElementMixin element) {
    if (element.isAugmentation) {
      _write('augment ');
    }

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
  void writeEnumElement(EnumElementImpl element) {
    if (element.isAugmentation) {
      _write('augment ');
    }

    _write('enum ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _writeTypesIfNotEmpty(' with ', element.mixins);
    _writeTypesIfNotEmpty(' implements ', element.interfaces);
  }

  @override
  void writeExecutableElement(ExecutableElementOrMember element, String name) {
    if (element.isAugmentation) {
      _write('augment ');
    }

    if (element.kind != ElementKind.SETTER) {
      _writeType(element.returnType);
      _write(' ');
    }

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
  void writeExtensionElement(ExtensionElementImpl element) {
    if (element.isAugmentation) {
      _write('augment ');
    }

    _write('extension');
    if (element.displayName.isNotEmpty) {
      _write(' ');
      _write(element.displayName);
      _writeTypeParameters(element.typeParameters);
    }
    _write(' on ');
    _writeType(element.extendedType);
  }

  @override
  void writeExtensionTypeElement(ExtensionTypeElementImpl element) {
    if (element.isAugmentation) {
      _write('augment ');
    }

    _write('extension type ');
    _write(element.displayName);

    _writeTypeParameters(element.typeParameters);
    _write('(');
    _writeType(element.representation.type);
    _write(' ');
    _write(element.representation.name);
    _write(')');

    _writeTypesIfNotEmpty(' implements ', element.interfaces);
  }

  @override
  void writeFormalParameter(ParameterElementMixin element) {
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
  void writeFunctionType(FunctionTypeImpl type) {
    // zmtzawqlp
    if (type.alias != null) {
      final DartTypeAutoImport? dartTypeAutoImport =
          DartTypeAutoImportHelper().getImport(type);
      if (dartTypeAutoImport != null) {
        _write(
          '${dartTypeAutoImport.prefix}.${type.alias!.element.displayName}',
        );
        return;
      }
    }
    if (_maybeWriteTypeAlias(type)) {
      return;
    }

    type = _uniqueTypeParameters(type);

    _writeType(type.returnType);
    _write(' Function');
    _writeTypeParameters2(type.typeParameters);
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
  void writeInterfaceType(InterfaceType type) {
    // zmtzawqlp
    final DartTypeAutoImport? dartTypeAutoImport =
        DartTypeAutoImportHelper().getImport(type);
    if (dartTypeAutoImport != null) {
      if (type.alias != null) {
        _write(
          '${dartTypeAutoImport.prefix}.${type.alias!.element.displayName}',
        );
      } else {
        _write(
          '${dartTypeAutoImport.prefix}.${type.element3.name3 ?? '<null>'}',
        );
      }
    } else {
      if (_maybeWriteTypeAlias(type)) {
        return;
      }

      _write(type.element3.name3 ?? '<null>');
    }

    _writeTypeArguments(type.typeArguments);
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeInvalidType() {
    _write('InvalidType');
  }

  @override
  void writeLibraryElement(LibraryElementImpl element) {
    _write('library ');
    _write('${element.source.uri}');
  }

  @override
  void writeMixinElement(MixinElementImpl element) {
    if (element.isAugmentation) {
      _write('augment ');
    }
    if (element.isBase) {
      _write('base ');
    }
    _write('mixin ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _writeTypesIfNotEmpty(' on ', element.superclassConstraints);
    _writeTypesIfNotEmpty(' implements ', element.interfaces);
  }

  @override
  void writeNeverType(NeverType type) {
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
    var libraryImports = element.imports;
    var displayName = element.displayName;
    if (libraryImports.isEmpty) {
      _write('as ');
      _write(displayName);
      return;
    }
    var first = libraryImports.first;
    _write("import '${first.libraryName}' as $displayName;");
    if (libraryImports.length == 1) {
      return;
    }
    for (final libraryImport in libraryImports.sublist(1)) {
      _write("\nimport '${libraryImport.libraryName}' as $displayName;");
    }
  }

  @override
  void writePrefixElement2(PrefixElementImpl2 element) {
    var libraryImports = element.imports;
    var displayName = element.displayName;
    if (libraryImports.isEmpty) {
      _write('as ');
      _write(displayName);
      return;
    }
    var first = libraryImports.first;
    _write("import '${first.libraryName}' as $displayName;");
    if (libraryImports.length == 1) {
      return;
    }
    for (final libraryImport in libraryImports.sublist(1)) {
      _write("\nimport '${libraryImport.libraryName}' as $displayName;");
    }
  }

  @override
  void writeRecordType(RecordTypeImpl type) {
    if (_maybeWriteTypeAlias(type)) {
      return;
    }

    var positionalFields = type.positionalFields;
    var namedFields = type.namedFields;
    var fieldCount = positionalFields.length + namedFields.length;
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

    // Add trailing comma for record types with only one position field.
    if (positionalFields.length == 1 && namedFields.isEmpty) {
      _write(',');
    }

    _write(')');
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeTypeAliasElement(TypeAliasElementImpl element) {
    if (element.isAugmentation) {
      _write('augment ');
    }

    _write('typedef ');
    _write(element.displayName);
    _writeTypeParameters(element.typeParameters);
    _write(' = ');

    var aliasedElement = element.aliasedElement;
    if (aliasedElement != null) {
      aliasedElement.appendTo(this);
    } else {
      _writeType(element.aliasedType);
    }
  }

  @override
  void writeTypeParameter(TypeParameterElementImpl element) {
    var variance = element.variance;
    if (!element.isLegacyCovariant && variance != Variance.unrelated) {
      _write(variance.keyword);
      _write(' ');
    }

    _write(element.displayName);

    var bound = element.bound;
    if (bound != null) {
      _write(' extends ');
      _writeType(bound);
    }
  }

  @override
  void writeTypeParameter2(TypeParameterElementImpl2 element) {
    var variance = element.variance;
    if (!element.isLegacyCovariant && variance != Variance.unrelated) {
      _write(variance.keyword);
      _write(' ');
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
    var promotedBound = type.promotedBound;
    if (promotedBound != null) {
      var hasSuffix = type.nullabilitySuffix != NullabilitySuffix.none;
      if (hasSuffix) {
        _write('(');
      }
      _write(type.element3.displayName);
      _write(' & ');
      _writeType(promotedBound);
      if (hasSuffix) {
        _write(')');
      }
    } else {
      _write(type.element3.displayName);
    }
    _writeNullability(type.nullabilitySuffix);
  }

  @override
  void writeUnknownInferredType() {
    _write('_');
  }

  @override
  void writeVariableElement(VariableElementOrMember element) {
    _writeType(element.type);
    _write(' ');
    _write(element.displayName);
  }

  @override
  void writeVoidType() {
    _write('void');
  }

  bool _maybeWriteTypeAlias(DartType type) {
    if (preferTypeAlias) {
      if (type.alias case var alias?) {
        _write(alias.element2.name3 ?? '<null>');
        _writeTypeArguments(alias.typeArguments);
        _writeNullability(type.nullabilitySuffix);
        return true;
      }
    }
    return false;
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
    List<ParameterElementMixin> parameters, {
    required bool forElement,
    bool allowMultiline = false,
  }) {
    // Assume the display string looks better wrapped when there are at least
    // three parameters. This avoids having to pre-compute the single-line
    // version and know the length of the function name/return type.
    var multiline = allowMultiline && _multiline && parameters.length >= 3;

    // The prefix for open groups is included in separator for single-line but
    // not for multiline so must be added explicitly.
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
        case NullabilitySuffix.star:
          _write('*');
        case NullabilitySuffix.none:
      }
    }
  }

  void _writeType(TypeImpl type) {
    type.appendTo(this);
  }

  void _writeTypeArguments(List<DartType> typeArguments) {
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

  void _writeTypeIfNotObject(String prefix, TypeImpl? type) {
    if (type != null && !type.isDartCoreObject) {
      _write(prefix);
      _writeType(type);
    }
  }

  void _writeTypeParameters(List<TypeParameterElementImpl> elements) {
    if (elements.isEmpty) return;

    _write('<');
    for (var i = 0; i < elements.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      elements[i].appendTo(this);
    }
    _write('>');
  }

  void _writeTypeParameters2(List<TypeParameterElement2> elements) {
    if (elements.isEmpty) return;

    _write('<');
    for (var i = 0; i < elements.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      (elements[i] as TypeParameterElementImpl2).appendTo(this);
    }
    _write('>');
  }

  void _writeTypes(List<TypeImpl> types) {
    for (var i = 0; i < types.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      _writeType(types[i]);
    }
  }

  void _writeTypesIfNotEmpty(String prefix, List<TypeImpl> types) {
    if (types.isNotEmpty) {
      _write(prefix);
      _writeTypes(types);
    }
  }

  void _writeWithoutDelimiters(
    ParameterElementMixin element, {
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

  static FunctionTypeImpl _uniqueTypeParameters(FunctionTypeImpl type) {
    if (type.typeParameters.isEmpty) {
      return type;
    }

    var referencedTypeParameters = <TypeParameterElement2>{};

    void collectTypeParameters(DartType? type) {
      if (type is TypeParameterType) {
        referencedTypeParameters.add(type.element3);
      } else if (type is FunctionType) {
        for (final typeParameter in type.typeParameters) {
          collectTypeParameters(typeParameter.bound);
        }
        for (final parameter in type.formalParameters) {
          collectTypeParameters(parameter.type);
        }
        collectTypeParameters(type.returnType);
      } else if (type is InterfaceType) {
        for (final typeArgument in type.typeArguments) {
          collectTypeParameters(typeArgument);
        }
      }
    }

    collectTypeParameters(type);
    referencedTypeParameters.removeAll(type.typeParameters);

    var namesToAvoid = <String>{};
    for (final typeParameter in referencedTypeParameters) {
      namesToAvoid.add(typeParameter.displayName);
    }

    var newTypeParameters = <TypeParameterElementImpl2>[];
    for (final typeParameter in type.typeParameters) {
      var name = typeParameter.name3!;
      for (var counter = 0; !namesToAvoid.add(name); counter++) {
        const unicodeSubscriptZero = 0x2080;
        const unicodeZero = 0x30;

        var subscript = String.fromCharCodes(
          '$counter'.codeUnits.map((n) {
            return unicodeSubscriptZero + (n - unicodeZero);
          }),
        );

        name = typeParameter.name3! + subscript;
      }

      var newTypeParameter = TypeParameterElementImpl(name, -1);
      newTypeParameter.name2 = name;
      newTypeParameter.bound = typeParameter.bound;
      newTypeParameters.add(newTypeParameter.asElement2);
    }

    return replaceTypeParameters(type, newTypeParameters);
  }
}

enum _WriteFormalParameterKind { requiredPositional, optionalPositional, named }

extension on LibraryImportElementImpl {
  String get libraryName {
    if (uri case DirectiveUriWithRelativeUriString uri) {
      return uri.relativeUriString;
    }
    return '<unknown>';
  }
}
