import 'arg.dart';

class RouteHelper extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Whether generate xxx_route_helper.dart';

  @override
  String get name => 'route-helper';
}
