import 'arg.dart';

class ArgumentsCaseSensitive extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => true;

  @override
  String get help => 'arguments is case sensitive or not';

  @override
  String get name => 'arguments-case-sensitive';
}
