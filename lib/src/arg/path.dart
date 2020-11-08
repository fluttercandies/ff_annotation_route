import 'arg.dart';

class Path extends Argument<String> {
  @override
  String get abbr => 'p';

  @override
  String get defaultsTo => '.';

  @override
  String get help => 'Flutter project root path';

  @override
  String get name => 'path';
}
