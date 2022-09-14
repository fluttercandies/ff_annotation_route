import 'arg.dart';

class FastMode extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help =>
      'Whether use fast mode to analyze dart file, if yes, it doesn\'t support super parameters.';

  @override
  String get name => 'fast-mode';
}
