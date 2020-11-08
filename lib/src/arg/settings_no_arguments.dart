import 'arg.dart';

class SettingsNoArguments extends Argument<bool> {
  @override
  String get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help =>
      'Whether RouteSettings has arguments(for lower flutter sdk)';

  @override
  String get name => 'no-arguments';
}
