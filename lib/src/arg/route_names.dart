import 'arg.dart';

class RouteNames extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Whether generate route names as a list';

  @override
  String get name => 'route-names';
}
