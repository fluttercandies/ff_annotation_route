import 'arg.dart';

class Package extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Is it a package';

  @override
  String get name => 'package';
}
