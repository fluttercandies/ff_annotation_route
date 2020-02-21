import 'package:ff_annotation_route/src/command/command.dart';

class Save extends Command {

  @override
  String get description => 'Whether save commands in local, it will read next time to be execute if no commands.';

  @override
  String get full => '--save';

  @override
  String get short => '-s';
}
