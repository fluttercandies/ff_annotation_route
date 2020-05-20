import 'command.dart';

class RoutesFileOutput extends Command with CommandValue {
  @override
  String get description =>
      'The path of routes file. It is relative to the lib directory.';

  @override
  String get full => '--routes-file-output';

  @override
  String get short => '-rfo';

  @override
  String toString() => '$full,$value';
}
