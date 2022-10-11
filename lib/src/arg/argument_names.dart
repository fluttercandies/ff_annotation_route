import 'arg.dart';

class ArgumentNames extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help =>
      'Whether generate page argument names in helper class on super-arguments mode';

  @override
  String get name => 'argument-names';
}
