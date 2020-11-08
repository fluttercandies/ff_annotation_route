import 'arg.dart';

class SupperArguments extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Whether generate page arguments helper';

  @override
  String get name => 'supper-arguments';
}
