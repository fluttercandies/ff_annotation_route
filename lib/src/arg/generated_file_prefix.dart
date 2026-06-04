import 'arg.dart';

class GeneratedFilePrefix extends Argument<String?> {
  @override
  String? get abbr => null;

  @override
  String get defaultsTo => '';

  @override
  String get help =>
      'Replace packageName in generated route files, for example foo for foo_route(.g).dart and foo_routes(.g).dart';

  @override
  String get name => 'generated-file-prefix';
}
