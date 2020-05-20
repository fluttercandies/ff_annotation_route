import 'command.dart';

class Output extends Command with CommandValue {
  @override
  String get description =>
      'The path of main project route file and helper file.It is relative to the lib directory.';

  @override
  String get full => '--output';

  @override
  String get short => '-o';

  @override
  String toString() => '$full,$value';
}
