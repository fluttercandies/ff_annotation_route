import 'package:ff_annotation_route/src/command/help.dart';
import 'package:ff_annotation_route/src/command/path.dart';
import 'package:ff_annotation_route/src/command/route_constants.dart';
import 'package:ff_annotation_route/src/command/route_helper.dart';
import 'package:ff_annotation_route/src/command/route_names.dart';
import 'package:ff_annotation_route/src/command/routes_file_output.dart';
import 'package:ff_annotation_route/src/command/save.dart';
import 'package:ff_annotation_route/src/command/settings_no_arguments.dart';
import 'package:io/ansi.dart';

import 'git.dart';
import 'output.dart';
import 'package.dart';
import 'settings_no_is_initial_route.dart';

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
    return '$full';
  }

  //help of command
  String get command => '$short${' ' * (3 - short.length)}, $full';
}

class CommandValue {
  String value;
}

final List<Command> ffCommands = <Command>[
  Help(),
  Path(),
  Output(),
  RouteConstants(),
  RouteHelper(),
  RouteNames(),
  Save(),
  SettingsNoArguments(),
  Git(),
  Package(),
  SettingsNoIsInitialRoute(),
  RoutesFileOutput(),
];

List<Command> initCommands(List<String> arguments) {
  final List<Command> result = <Command>[];
  for (int i = 0; i < arguments.length; i++) {
    final String argument = arguments[i].trim();
    final Command command = ffCommands.firstWhere(
      (Command element) => element.contains(argument),
      orElse: () => null,
    );
    if (command != null) {
      if (command is CommandValue) {
        i++;
        if (i >= arguments.length || arguments[i].startsWith('-')) {
          print(red.wrap('Miss value of ${command.full}.'));
          return null;
        }
        (command as CommandValue).value = arguments[i];
      }
      result.add(command);
    } else {
      print(red.wrap(
          'Could not find an option or flag "$argument". ${yellow.wrap('ff_route --help')}.'));
      return null;
    }
  }
  return result;
}
