import 'arg.dart';

class NullSafety extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => true;

  @override
  String get help => 'enable null-safety';

  @override
  String get name => 'null-safety';
}
