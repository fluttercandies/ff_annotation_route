import 'package:ff_annotation_route/src/command/command.dart';

class Git extends Command with CommandValue {
  @override
  String get description => 'Whether scan git lib(you should specify package names and split multiple by ,)';

  @override
  String get full => '--git';

  @override
  String get short => '-g';

  @override
  String toString() {
    return '$full,$value';
  }

  //help of command
  @override
  String get command =>
      '$short${' ' * (3 - short.length)} , $full package1,package2,package3';
}
