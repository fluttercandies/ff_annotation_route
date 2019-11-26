import 'dart:io';

Future<void> formatFile(File file) async {
  if (file == null) {
    return;
  }
  print("format file : ${file?.absolute?.path}");
  Process.runSync(
    "flutter",
    ["format", file?.absolute?.path],
  );
}
