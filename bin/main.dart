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
import 'package:ff_annotation_route/src/command/save.dart';
import 'package:ff_annotation_route/src/command/settings_no_arguments.dart';
import 'package:ff_annotation_route/src/command/settings_no_is_initial_route.dart';
import 'package:ff_annotation_route/src/package_graph.dart';
import 'dart:io' as io;
import 'package:io/ansi.dart';
import 'package:path/path.dart';

const String cmmandsFile = 'ff_annotation_route_commands';

void main(List<String> arguments) {
  final argumentsIsEmpty = arguments.isEmpty;
  if (arguments.isEmpty) {
    final file = io.File(join('./', cmmandsFile));
    if (file.existsSync()) {
      arguments = file.readAsStringSync().split(',');
    }
  }

  if (arguments.isEmpty) {
    print(help);
    return;
  }

  final commmands = initCommands(arguments);
  if (commmands == null) {
    return;
  }

  if (commmands.isEmpty) {
    print(red.wrap(
        '''No available commands found.\nRun 'ff_route -h' for available commands and options.'''));
    return;
  }

  if (commmands.firstWhere(
        (element) => element is Help,
        orElse: () => null,
      ) !=
      null) {
    print(help);
    return;
  }

  final before = DateTime.now();

  print(green.wrap('\nff_annotation_route ------ Start'));

  if (argumentsIsEmpty) {
    print(yellow
        .wrap('execute commands from local.\n${getCommandsHelp(commmands)}'));
  }

  final pathCommand = commmands.firstWhere(
    (element) => element is Path,
    orElse: () => null,
  );
  final packageGraph = pathCommand != null
      ? PackageGraph.forPath((pathCommand as Path).value)
      : PackageGraph.forThisPackage();

  final generateRouteNames = commmands.firstWhere(
        (element) => element is RouteNames,
        orElse: () => null,
      ) !=
      null;

  final generateRouteConstants = commmands.firstWhere(
        (element) => element is RouteConstants,
        orElse: () => null,
      ) !=
      null;

  final generateRouteHelper = commmands.firstWhere(
        (element) => element is RouteHelper,
        orElse: () => null,
      ) !=
      null;

  final routeSettingsNoArguments = generateRouteHelper &&
      commmands.firstWhere(
            (element) => element is SettingsNoArguments,
            orElse: () => null,
          ) !=
          null;

  final git = commmands.firstWhere(
    (element) => element is Git,
    orElse: () => null,
  );
  var gitNames = [];
  if (git != null) {
    gitNames = (git as Git).value.split(',');
  }

  final isPackage = commmands.firstWhere(
        (element) => element is Package,
        orElse: () => null,
      ) !=
      null;

  final routeSettingsNoIsInitialRoute = generateRouteHelper &&
      commmands.firstWhere(
            (element) => element is SettingsNoIsInitialRoute,
            orElse: () => null,
          ) !=
          null;

  //only check path which imports ff_annotation_route
  final annotationPackages = packageGraph.allPackages.values
      .where((x) =>
          (x.dependencyType == DependencyType.path ||
              (x.dependencyType == DependencyType.github &&
                  gitNames.firstWhere(
                        (key) => x.name == key,
                        orElse: () => null,
                      ) !=
                      null)) &&
          (x.dependencies.firstWhere(
                (dep) => dep?.name == 'ff_annotation_route',
                orElse: () => null,
              ) !=
              null))
      .toList();

  final rootAnnotationRouteEnable =
      annotationPackages.contains(packageGraph.root);
  if (!rootAnnotationRouteEnable) {
    annotationPackages.add(packageGraph.root);
  }

  final Output output =
      commmands.firstWhere((t) => t is Output, orElse: () => null);
  String outputPath;
  if (output != null) {
    outputPath = output.value;
  }

  generate(
    annotationPackages,
    generateRouteNames: generateRouteNames,
    outputPath: outputPath,
    generateRouteConstants: generateRouteConstants,
    generateRouteHelper: generateRouteHelper,
    routeSettingsNoArguments: routeSettingsNoArguments,
    rootAnnotationRouteEnable: rootAnnotationRouteEnable,
    isPackage: isPackage,
    routeSettingsNoIsInitialRoute: routeSettingsNoIsInitialRoute,
  );
  final saveCommand = commmands.firstWhere(
    (element) => element is Save,
    orElse: () => null,
  );

  if (saveCommand != null) {
    final file = io.File(join(packageGraph.root.path, cmmandsFile));
    if (!file.existsSync()) {
      file.createSync();
    }

    commmands.remove(saveCommand);

    file.writeAsStringSync(
        commmands.toString().replaceAll('[', '').replaceAll(']', ''));
    print(green.wrap(
        'Save commands successfully: ${commmands}.\n\nYou can run "ff_route" directly in next time.'));
  }

  final diff = DateTime.now().difference(before);
  print(green.wrap('\nff_annotation_route ------ End [$diff]'));
}
