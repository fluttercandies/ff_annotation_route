import 'arg.dart';

class GenerateFileImportPackages extends Argument<List<String>> {
  @override
  String get name => 'generate-file-import-packages';

  @override
  String? get abbr => null;

  @override
  List<String>? get defaultsTo => null;

  @override
  String get help =>
      'Which package should auto generate file import path into exts.';
}
