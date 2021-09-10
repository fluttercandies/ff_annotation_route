import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';

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

void writeImports(List<String> imports, StringBuffer sb) {
  // Remove empty imports.
  imports.removeWhere((String v) => v.trim().isEmpty);
  if (imports.isNotEmpty) {
    sb.write('\n');
    // Trim all imports and de-duplication.
    imports = imports.map((String v) => v.trim()).toSet().toList();
    imports.sort((String a, String b) {
      final int _compare = a.compareTo(b);
      // First sort dart imports.
      if (a.isDartImport) {
        return 2 + _compare;
      }
      // Then package imports.
      if (a.isPackageImport) {
        return 1 + _compare;
      }
      // Others imports at last.
      return a.compareTo(b);
    });

    bool _startToWriteOtherImports = false;
    for (int i = 0; i < imports.length; i++) {
      final String _import = imports[i];
      if (!_startToWriteOtherImports &&
          !_import.isDartImport &&
          !_import.isPackageImport) {
        _startToWriteOtherImports = true;
        sb.write('\n');
      }
      sb.write('${imports[i]}\n');
    }

    sb.write('\n');
  }
}

extension _ImportExtension on String {
  bool get isDartImport => startsWith(_importExp('dart'));

  bool get isPackageImport => startsWith(_importExp('package'));
}

RegExp _importExp(String startsWith) =>
    RegExp('^(import [\'"]$startsWith:)[\s\S]*');
