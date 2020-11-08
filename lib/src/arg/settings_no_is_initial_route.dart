import 'arg.dart';

class SettingsNoIsInitialRoute extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help =>
      'Whether RouteSettings has isInitialRoute(for higher flutter sdk)';

  @override
  String get name => 'no-is-initial-route';
}
