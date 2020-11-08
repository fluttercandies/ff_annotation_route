import 'dart:io' as io;
import 'dart:io';

import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/package_graph.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart';

const String argumentsFile = 'ff_annotation_route_commands';
const String debugCommands =
    '--route-constants --route-helper --route-names --no-is-initial-route --path example/ -g xx,dd,ff --supper-arguments';

Future<void> main(List<String> arguments) async {
  //debug
  //arguments = debugCommands.split(' ');
  bool runFromLocal = false;
  if (arguments.isEmpty) {
    final io.File file = io.File(join('./', argumentsFile));
    if (file.existsSync()) {
      final String content = file.readAsStringSync();
      if (content.contains(',')) {
        //old style
        arguments = content.split(',');
      } else {
        arguments = content.split(' ');
      }
      runFromLocal = true;
    }
  }

  //keep old work
  for (int i = 0; i < arguments.length; i++) {
    if (arguments[i] == '-rc') {
      arguments[i] = '--route-constants';
    } else if (arguments[i] == '-rh') {
      arguments[i] = '--route-helper';
    } else if (arguments[i] == '-rn') {
      arguments[i] = '--route-names';
    } else if (arguments[i] == '-rfo') {
      arguments[i] = '--routes-file-output';
    } else if (arguments[i] == '-na') {
      arguments[i] = '--no-arguments';
    }
  }

  final Help help = Help();
  final Path path = Path();
  final Output output = Output();
  final Git git = Git();
  final RoutesFileOutput routesFileOutput = RoutesFileOutput();
  final RouteNames routeNames = RouteNames();
  final RouteHelper routeHelper = RouteHelper();
  final RouteConstants routeConstants = RouteConstants();
  final SettingsNoArguments settingsNoArguments = SettingsNoArguments();
  final Package package = Package();
  final SettingsNoIsInitialRoute settingsNoIsInitialRoute =
      SettingsNoIsInitialRoute();
  final SupperArguments supperArguments = SupperArguments();
  final Save save = Save();
  parseArgs(arguments);

  if (arguments.isEmpty || help.value) {
    print(green.wrap(parser.usage));
    return;
  }

  final DateTime before = DateTime.now();

  print(green.wrap('\nff_annotation_route ------ Start'));

  final PackageGraph packageGraph = PackageGraph.forPath(path.value);

  final bool shouldGenerateRouteNames = routeNames.value;

  final bool shouldGenerateRouteConstants = routeConstants.value;

  final bool shouldGenerateRouteHelper = routeHelper.value;

  final bool isRouteSettingsNoArguments = settingsNoArguments.value;

  final List<String> gitNames = git.value;

  final bool isPackage = package.value;

  final bool isRouteSettingsHasIsInitialRoute = settingsNoIsInitialRoute.value;

  final bool enableSupperArguments = supperArguments.value;

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

  final String outputPath = output.value;

  final String routesFileOutputPath = routesFileOutput.value;

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
    enableSupperArguments: enableSupperArguments,
  );

  if (save.value && !runFromLocal) {
    final File file = File(join('./', argumentsFile));
    if (!file.existsSync()) {
      file.createSync();
    }
    String argumentsS = '';
    for (final String item in arguments) {
      argumentsS += '$item ';
    }
    file.writeAsStringSync(argumentsS.trim());
  }

  final Duration diff = DateTime.now().difference(before);
  print(green.wrap('\nff_annotation_route ------ End [$diff]'));
}
