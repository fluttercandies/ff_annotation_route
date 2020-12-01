import 'arg.dart';

class Name extends Argument<String> {
  @override
  String get abbr => 'n';

  @override
  String get defaultsTo => 'Routes';

  @override
  String get help => 'Routes constant class name.';

  @override
  String get name => 'name';
}
