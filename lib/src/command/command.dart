import 'package:ff_annotation_route/src/command/help.dart';
import 'package:ff_annotation_route/src/command/path.dart';
import 'package:ff_annotation_route/src/command/route_constants.dart';
import 'package:ff_annotation_route/src/command/route_helper.dart';
import 'package:ff_annotation_route/src/command/route_names.dart';
import 'package:ff_annotation_route/src/command/save.dart';
import 'package:ff_annotation_route/src/command/settings_no_arguments.dart';

abstract class Command {
  /// full command
  String get full;

  /// short command
  /// not long than 3 chars
  String get short;

  /// description of command
  String get description;

  bool contains(String argument) => argument == full || argument == short;

  @override
  String toString() {
    return '$short';
  }

  //help of command
  String get command => '$short${' ' * (3 - short.length)}, $full';
}

final List<Command> commands = [
  Help(),
  Path(),
  RouteConstants(),
  RouteHelper(),
  RouteNames(),
  Save(),
  SettingsNoArguments(),
];

List<Command> initCommands(List<String> arguments) {
  final result = <Command>[];
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i].trim();
    final command = commands.firstWhere(
        (element) => element.contains(
              argument,
            ),
        orElse: () => null);
    if (command != null) {
      if (command is Path) {
        i++;
        if (i >= arguments.length || arguments[i].startsWith('-')) {
          throw Exception('miss value of path');
        }
        command.value = arguments[i];
      }
      result.add(command);
    }
  }
  return result;
}
