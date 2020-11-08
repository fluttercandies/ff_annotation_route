import 'arg.dart';

class RoutesFileOutput extends Argument<String> {
  @override
  String get abbr => null;

  @override
  String get defaultsTo => null;

  @override
  String get help =>
      'The path of routes file. It is relative to the lib directory';

  @override
  String get name => 'routes-file-output';
}
