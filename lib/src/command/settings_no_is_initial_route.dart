import 'package:ff_annotation_route/src/command/command.dart';

class SettingsNoIsInitialRoute extends Command {
  @override
  String get description =>
      'Whether RouteSettings has isInitialRoute(for higher flutter sdk).';

  @override
  String get full => '--no-is-initial-route';

  @override
  String get short => '   ';

  @override
  String get command => '$short${' ' * (3 - short.length)}   $full';
}
