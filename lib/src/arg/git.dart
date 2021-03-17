import 'arg.dart';

class Git extends Argument<List<String>> {
  @override
  String get abbr => 'g';

  @override
  List<String>? get defaultsTo => null;

  @override
  String get help =>
      'scan git lib(you should specify package names and split multiple by ,)';

  @override
  String get name => 'git';
}
