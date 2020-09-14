import 'package:ff_annotation_route/src/command/command.dart';

class RouteNames extends Command {
  @override
  String get description => 'Whether generate route names as a list.';

  @override
  String get full => '--route-names';

  @override
  String get short => '-rn';
}
