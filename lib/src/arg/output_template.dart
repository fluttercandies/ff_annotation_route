import 'arg.dart';

class OutputTemplate extends Argument<String?> {
  @override
  String? get abbr => null;

  @override
  String? get defaultsTo => null;

  @override
  String get help =>
      'The output template type. e.g. "go_router" to generate go_router configuration. default is null which means to generate standard(switch case) Flutter routes file.';

  @override
  String get name => 'output-template';
}
