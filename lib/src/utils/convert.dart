import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';

T toT<T>(Expression expression) {
  if ('' is T && expression is SimpleStringLiteral) {
    return expression.value as T;
  } else if ('' is T && expression is AdjacentStrings) {
    return expression.stringValue as T;
  } else if (<String>[] is T && expression is ListLiteral) {
    final List<String> result = <String>[];
    for (final SyntacticEntity item in expression.childEntities) {
      if (item is SimpleStringLiteral) {
        result.add(item.value);
      } else if (item is AdjacentStrings) {
        result.add(item.stringValue);
      }
    }
    return result as T;
  } else if (false is T && expression is BooleanLiteral) {
    return expression.value as T;
  }
  return null;
}

String safeToString(String input) {
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
