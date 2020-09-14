import 'dart:io' as io;

import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/command/command.dart';
import 'package:ff_annotation_route/src/command/git.dart';
import 'package:ff_annotation_route/src/command/help.dart';
import 'package:ff_annotation_route/src/command/output.dart';
import 'package:ff_annotation_route/src/command/package.dart';
import 'package:ff_annotation_route/src/command/path.dart';
import 'package:ff_annotation_route/src/command/route_constants.dart';
import 'package:ff_annotation_route/src/command/route_helper.dart';
import 'package:ff_annotation_route/src/command/route_names.dart';
import 'package:ff_annotation_route/src/command/routes_file_output.dart';
import 'package:ff_annotation_route/src/command/save.dart';
import 'package:ff_annotation_route/src/command/settings_no_arguments.dart';
import 'package:ff_annotation_route/src/command/settings_no_is_initial_route.dart';
import 'package:ff_annotation_route/src/package_graph.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart';

const String commandsFile = 'ff_annotation_route_commands';

void main(List<String> arguments) {
  final bool argumentsIsEmpty = arguments.isEmpty;
  bool oldStyle = false;
  if (arguments.isEmpty) {
    final io.File file = io.File(join('./', commandsFile));
    if (file.existsSync()) {
      final String content = file.readAsStringSync();
      if (content.contains(',')) {
        //old style
        arguments = content.split(',');
        oldStyle = true;
      } else {
        arguments = content.split(' ');
      }
    }
  }

  if (arguments.isEmpty) {
    print(help);
    return;
  }

  final List<Command> commands = initCommands(arguments);
  if (commands == null) {
    return;
  }

  if (commands.isEmpty) {
    print(red.wrap(
        '''No available commands found.\nRun 'ff_route -h' for available commands and options.'''));
    return;
  }

  if (commands.firstWhere((Command element) => element is Help,
          orElse: () => null) !=
      null) {
    print(help);
    return;
  }

  final DateTime before = DateTime.now();

  print(green.wrap('\nff_annotation_route ------ Start'));

  if (argumentsIsEmpty) {
    print(yellow
        .wrap('execute commands from local.\n${getCommandsHelp(commands)}'));
  }

  final Command pathCommand = commands.firstWhere(
    (Command element) => element is Path,
    orElse: () => null,
  );
  final PackageGraph packageGraph = pathCommand != null
      ? PackageGraph.forPath((pathCommand as Path).value)
      : PackageGraph.forThisPackage();

  final bool shouldGenerateRouteNames = commands.firstWhere(
          (Command element) => element is RouteNames,
          orElse: () => null) !=
      null;

  final bool shouldGenerateRouteConstants = commands.firstWhere(
          (Command element) => element is RouteConstants,
          orElse: () => null) !=
      null;

  final bool shouldGenerateRouteHelper = commands.firstWhere(
          (Command element) => element is RouteHelper,
          orElse: () => null) !=
      null;

  final bool isRouteSettingsNoArguments = shouldGenerateRouteHelper &&
      commands.firstWhere((Command element) => element is SettingsNoArguments,
              orElse: () => null) !=
          null;

  final Command git = commands.firstWhere(
    (Command element) => element is Git,
    orElse: () => null,
  );
  List<String> gitNames;
  gitNames = <String>[];
  if (git != null) {
    gitNames = (git as Git).value.split(',');
  }

  final bool isPackage = commands.firstWhere(
          (Command element) => element is Package,
          orElse: () => null) !=
      null;

  final bool isRouteSettingsHasIsInitialRoute = shouldGenerateRouteHelper &&
      commands.firstWhere(
              (Command element) => element is SettingsNoIsInitialRoute,
              orElse: () => null) !=
          null;

  // Only check path which imports ff_annotation_route
  final List<PackageNode> annotationPackages =
      packageGraph.allPackages.values.where(
    (PackageNode x) {
      final bool matchPackage = x.dependencyType == DependencyType.path ||
          (x.dependencyType == DependencyType.github &&
              gitNames.firstWhere((String key) => x.name == key,
                      orElse: () => null) !=
                  null);
      final bool matchFFRoute = x.dependencies.firstWhere(
            (PackageNode dep) => dep?.name == 'ff_annotation_route',
            orElse: () => null,
          ) !=
          null;
      return matchPackage && matchFFRoute;
    },
  ).toList();

  final bool isRootAnnotationRouteEnabled =
      annotationPackages.contains(packageGraph.root);
  if (!isRootAnnotationRouteEnabled) {
    annotationPackages.add(packageGraph.root);
  }

  final Output output = commands.firstWhere((Command t) => t is Output,
      orElse: () => null) as Output;
  String outputPath;
  if (output != null) {
    outputPath = output.value;
  }

  final RoutesFileOutput routesFileOutput = commands.firstWhere(
      (Command t) => t is RoutesFileOutput,
      orElse: () => null) as RoutesFileOutput;
  String routesFileOutputPath;
  if (routesFileOutput != null) {
    routesFileOutputPath = routesFileOutput.value;
  }

  generate(
    annotationPackages,
    generateRouteNames: shouldGenerateRouteNames,
    outputPath: outputPath,
    generateRouteConstants: shouldGenerateRouteConstants,
    generateRouteHelper: shouldGenerateRouteHelper,
    routeSettingsNoArguments: isRouteSettingsNoArguments,
    rootAnnotationRouteEnable: isRootAnnotationRouteEnabled,
    isPackage: isPackage,
    routeSettingsNoIsInitialRoute: isRouteSettingsHasIsInitialRoute,
    routesFileOutputPath: routesFileOutputPath,
  );
  final Command saveCommand = commands.firstWhere(
    (Command element) => element is Save,
    orElse: () => null,
  );

  if (saveCommand != null || oldStyle) {
    final io.File file = io.File(join(packageGraph.root.path, commandsFile));
    if (!file.existsSync()) {
      file.createSync();
    }

    commands.remove(saveCommand);

    // file.writeAsStringSync(
    //     commands.toString().replaceAll('[', '').replaceAll(']', ''));

    final StringBuffer sb = StringBuffer();

    for (final Command command in commands) {
      final String commandS = command.toString();
      if (commandS.contains(',')) {
        for (final String item in commandS.split(',')) {
          sb.write('$item ');
        }
      } else {
        sb.write('$commandS ');
      }
    }

    final String saveCommands = sb.toString().trim();

    file.writeAsStringSync(saveCommands);

    print(green.wrap(
        'Save commands successfully: $saveCommands.\n\nYou can run "ff_route" directly in next time.'));
  }

  final Duration diff = DateTime.now().difference(before);
  print(green.wrap('\nff_annotation_route ------ End [$diff]'));
}
