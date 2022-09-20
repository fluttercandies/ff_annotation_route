import 'dart:io';

void processRun({
  required String executable,
  required String arguments,
  bool runInShell = false,
  String? workingDirectory,
}) {
  final ProcessResult result = Process.runSync(
    executable,
    arguments.split(' '),
    runInShell: runInShell,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    throw Exception(result.stderr);
  }
  print('${result.stdout}\n');
}
