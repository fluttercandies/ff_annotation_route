
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/command/command.dart';
import 'package:ff_annotation_route/src/command/help.dart';
import 'package:ff_annotation_route/src/command/path.dart';
import 'package:ff_annotation_route/src/command/route_constants.dart';
import 'package:ff_annotation_route/src/command/route_helper.dart';
import 'package:ff_annotation_route/src/command/route_names.dart';
import 'package:ff_annotation_route/src/command/save.dart';
import 'package:ff_annotation_route/src/command/settings_no_arguments.dart';
import 'package:ff_annotation_route/src/package_graph.dart';
import 'dart:io' as io;

import 'package:path/path.dart';

const String cmmandsFile = 'ff_annotation_route_commands';

void main(List<String> arguments) {
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
  if (commmands.isEmpty) {
    print(
        '''No available commands found.\n Run 'ff_route -h' for available commands and options''');
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

  print('ff_annotation_route ------ Start');

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

  //only check path which imports ff_annotation_route
  final annotationPackages = packageGraph.allPackages.values
      .where((x) =>
          x.dependencyType == DependencyType.path &&
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

  generate(
    annotationPackages,
    generateRouteNames: generateRouteNames,
    generateRouteConstants: generateRouteConstants,
    generateRouteHelper: generateRouteHelper,
    routeSettingsNoArguments: routeSettingsNoArguments,
    rootAnnotationRouteEnable: rootAnnotationRouteEnable,
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
  }

  final diff = DateTime.now().difference(before);
  print('\nff_annotation_route ------ End [$diff]');
}
