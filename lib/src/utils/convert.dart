import 'dart:convert';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:crypto/crypto.dart' as crypto;

T? toT<T>(Expression expression) {
  if ('' is T && expression is SimpleStringLiteral) {
    return expression.value as T;
  } else if ('' is T && expression is AdjacentStrings) {
    return expression.stringValue as T?;
  } else if (<String>[] is T && expression is ListLiteral) {
    final List<String> result = <String>[];
    for (final SyntacticEntity item in expression.childEntities) {
      if (item is SimpleStringLiteral) {
        result.add(item.value);
      } else if (item is AdjacentStrings) {
        result.add(item.stringValue!);
      }
    }
    return result as T;
  } else if (false is T && expression is BooleanLiteral) {
    return expression.value as T;
  }
  return null;
}

String? safeToString(String? input) {
  if (input == null) {
    return null;
  }
  if (input.contains('"')) {
    return "'''$input'''";
  } else if (input.contains("'")) {
    return '"$input"';
  }
  return "'$input'";
}

void writeImports(Set<String> imports, StringBuffer sb) {
  final List<String> dartImports = <String>[];
  final List<String> packageImports = <String>[];
  final List<String> otherImports = <String>[];
  final Set<String> distinctImports =
      imports.map((String e) => e.trim()).toSet();
  for (final String import in distinctImports) {
    if (import.isDartImport) {
      dartImports.add(import);
    } else if (import.isPackageImport) {
      packageImports.add(import);
    } else {
      otherImports.add(import);
    }
  }
  dartImports.sort((String a, String b) => a.compareTo(b));
  packageImports.sort((String a, String b) => a.compareTo(b));
  otherImports.sort((String a, String b) => a.compareTo(b));
  final String output = <String>[
    dartImports.join('\n'),
    packageImports.join('\n'),
    otherImports.join('\n')
  ].join('\n\n').trim();
  sb.write(output);
}

extension _ImportExtension on String {
  bool get isDartImport => contains('dart:');

  bool get isPackageImport => contains('package:');
}

extension MD5Extension on String {
  String get md5 => crypto.md5.convert(utf8.encode(this)).toString();
}
