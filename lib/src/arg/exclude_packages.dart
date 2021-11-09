import 'arg.dart';

class ExcludePackages extends Argument<List<String>> {
  @override
  String get name => 'exclude-packages';

  @override
  String? get abbr => null;

  @override
  List<String>? get defaultsTo => null;

  @override
  String get help => 'Exclude given packages from scanning';
}
