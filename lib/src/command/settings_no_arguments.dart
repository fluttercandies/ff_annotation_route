import 'package:ff_annotation_route/src/command/command.dart';

class SettingsNoArguments extends Command {

  @override
  String get description => 'Whether RouteSettings has arguments(for lower flutter sdk).';

  @override
  String get full => '--no-arguments';

  @override
  String get short => '-na';

}
