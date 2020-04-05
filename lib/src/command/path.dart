import 'package:ff_annotation_route/src/command/command.dart';

class Path extends Command with CommandValue {
  @override
  String get description => 'The path of folder to be executed with commands.';

  @override
  String get full => '--path';

  @override
  String get short => '-p';

  @override
  String toString() {
    return '$full $value';
  }

  //help of command
  @override
  String get command => '$short${' ' * (3 - short.length)} , $full [arguments]';
}
