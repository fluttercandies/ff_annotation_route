import 'arg.dart';

class ConstIgnore extends Argument<String?> {
  @override
  String? get abbr => null;

  @override
  String? get defaultsTo => null;

  @override
  String get help => 'The regular to ignore some route consts';

  @override
  String get name => 'const-ignore';
}
