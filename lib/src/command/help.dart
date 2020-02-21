import 'package:ff_annotation_route/src/command/command.dart';

class Help extends Command {
  @override
  String get description => 'Print this usage information.';

  @override
  String get full => '--help';

  @override
  String get short => '-h';
}

String get help {
  return '''\nManage your Flutter app development with ff_annotation_route.

Usage: ff_route <command> [arguments]

Available commands:
${getCommandsHelp(ffCommands)}
''';
}

String getCommandsHelp(List<Command> commands) {
  final maxLengthCommand = commands.reduce((value, element) =>
      value.command.length > element.command.length ? value : element);

  final sb = StringBuffer();
  for (var i = 0; i < commands.length; i++) {
    final command = commands[i];
    sb.write(
        '${command.command}${' ' * (maxLengthCommand.command.length - command.command.length + 5)}${command.description}\n');
  }
  return sb.toString();
}
