import 'arg.dart';

class GSuffix extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Whether the generated file is end with .g';

  @override
  String get name => 'g-suffix';
}
