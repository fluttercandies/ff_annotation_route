import 'arg.dart';

class RouteConstants extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Whether generate route names as constants';

  @override
  String get name => 'route-constants';
}
