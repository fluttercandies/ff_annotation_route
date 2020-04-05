import 'command.dart';

class Package extends Command {
  @override
  String get description => 'Is this a package.';

  @override
  String get full => '--package';

  @override
  String get short => '   ';

  @override
  String get command => '$short${' ' * (3 - short.length)}   $full';
}
