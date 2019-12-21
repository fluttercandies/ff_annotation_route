import 'dart:io';

Future<void> formatFile(File file) async {
  if (file == null) {
    return;
  }
  print("Format file : ${file?.absolute?.path}");
  Process.runSync(
    "flutter",
    ["format", file?.absolute?.path],
  );
}
