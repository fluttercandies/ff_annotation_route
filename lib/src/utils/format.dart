import 'dart:io';
import 'package:io/ansi.dart';

Future<void> formatFile(File file) async {
  if (file == null) {
    return;
  }

  if (!file.existsSync()) {
    print(red.wrap('format error: ${file?.absolute?.path} doesn\'t exist\n'));
    return;
  }

  processRunSync(
    executable: 'flutter',
    arguments: 'format ${file?.absolute?.path}',
    runInShell: true,
  );
}

void processRunSync({
  String executable,
  String arguments,
  bool runInShell = false,
}) {
  final ProcessResult result = Process.runSync(
    executable,
    arguments.split(' '),
    runInShell: runInShell,
  );
  if (result.exitCode != 0) {
    throw Exception(result.stderr);
  }
  print('${result.stdout}');
}
