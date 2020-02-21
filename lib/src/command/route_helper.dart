import 'package:ff_annotation_route/src/command/command.dart';

class RouteHelper extends Command {
  @override
  String get description => 'Whether generate xxx_route_helper.dart';

  @override
  String get full => '--route-helper';

  @override
  String get short => '-rh';
}
