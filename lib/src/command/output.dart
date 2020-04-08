import 'command.dart';

class Output extends Command with CommandValue {
  @override
  String get description =>
      'The main project route file is relative to the lib directory.';

  @override
  String get full => '--output';

  @override
  String get short => '-o';

  @override
  String toString() {
    return '$full,$value';
  }
}
