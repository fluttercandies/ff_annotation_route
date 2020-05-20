import 'package:ff_annotation_route/src/command/command.dart';

class RouteConstants extends Command{
  @override
  String get description => 'Whether generate route names as constants.';

  @override
  String get full => '--route-constants';

  @override
  String get short => '-rc';
}
