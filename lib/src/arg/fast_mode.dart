import 'arg.dart';

class FastMode extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => true;

  @override
  String get help =>
      'fast-mode: only analyze base on single dart file, it\'s fast.\nno-fast-mode: analyze base on whole packages and sdk, support super parameters and add parameters refer import automatically.';

  @override
  String get name => 'fast-mode';
}
