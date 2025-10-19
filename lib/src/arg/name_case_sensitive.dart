import 'arg.dart';

class NameCaseSensitive extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => true;

  @override
  String get help => 'route name is case sensitive or not';

  @override
  String get name => 'name-case-sensitive';
}
