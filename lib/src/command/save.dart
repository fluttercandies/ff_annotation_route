import 'package:ff_annotation_route/src/command/command.dart';

class Save extends Command {
  @override
  String get description =>
      'Whether save commands in local, it will execute commands from local if run "ff_route" without any commands.';

  @override
  String get full => '--save';

  @override
  String get short => '-s';
}
