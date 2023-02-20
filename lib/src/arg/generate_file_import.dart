import 'arg.dart';

class GenerateFileImport extends Argument<bool> {
  @override
  String? get abbr => null;

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'auto generate file import path into exts.';

  @override
  String get name => 'generate-file-import';
}
