import 'arg.dart';

class Help extends Argument<bool> {
  @override
  String get abbr => 'h';

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Help usage';

  @override
  String get name => 'help';
}
