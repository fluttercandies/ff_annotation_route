import 'arg.dart';

class Output extends Argument<String?> {
  @override
  String get abbr => 'o';

  @override
  String? get defaultsTo => null;

  @override
  String get help =>
      'The path of main project route file and helper file.It is relative to the lib directory';

  @override
  String get name => 'output';
}
