import 'arg.dart';

class SuperArguments extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Whether generate page arguments helper class';

  @override
  String get name => 'super-arguments';
}
