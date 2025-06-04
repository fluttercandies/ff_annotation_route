import 'dart:io' as io;
import 'dart:io';

import 'package:build_runner_core/build_runner_core.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/arg/arg_parser.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as path;

const String argumentsFile = 'ff_annotation_route_commands';

Future<void> main(List<String> arguments) async {
  bool runFromLocal = false;
  // debug, run local example，
  // ignore: dead_code
  if (true) {
    String project = 'example';
    final io.File file =
        io.File(path.join(path.current, project, argumentsFile));
    if (file.existsSync()) {
      final String content = '${file.readAsStringSync()} --path $project';

      arguments = content.split(' ');

      runFromLocal = true;
    }
  }

  if (arguments.isEmpty) {
    final io.File file = io.File(path.join(path.current, argumentsFile));
    if (file.existsSync()) {
      final String content = file.readAsStringSync();

      arguments = content.split(' ');

      runFromLocal = true;
    }
  }

  parseArgs(arguments);

  if (arguments.isEmpty || Args().help.value!) {
    print(green.wrap(parser.usage));
    return;
  }

  final DateTime before = DateTime.now();

  print(green.wrap('\nff_annotation_route ------ Start'));
  // processRun(
  //   executable: 'flutter',
  //   arguments: 'packages get',
  //   runInShell: true,
  //   workingDirectory: Args().path.value!,
  // );
  final PackageGraph packageGraph = await PackageGraph.forPath(Args().pathUri);

  // Only check path which imports ff_annotation_route_core or ff_annotation_route_library
  final List<PackageNode> annotationPackages =
      packageGraph.allPackages.values.where(
    (PackageNode x) {
      if (x.name == 'ff_annotation_route_library' ||
          x.name == 'ff_annotation_route_core' ||
          x.name == 'ff_annotation_route') {
        return false;
      }
      final bool matchPackage = x.dependencyType == DependencyType.path ||
          (x.dependencyType == DependencyType.github &&
              Args()
                      .gitNames
                      ?.firstWhereOrNull((String key) => x.name == key) !=
                  null);
      final bool matchFFRoute = x.dependencies.firstWhereOrNull(
            (PackageNode? dep) =>
                dep?.name == 'ff_annotation_route_core' ||
                dep?.name == 'ff_annotation_route_library',
          ) !=
          null;
      final bool isNotExcluded =
          x.name.isNotEmpty && !Args().excludedPackagesName.contains(x.name);

      return matchPackage && matchFFRoute && isNotExcluded;
    },
  ).toList();

  final bool isRootAnnotationRouteEnabled =
      annotationPackages.contains(packageGraph.root);
  if (!isRootAnnotationRouteEnabled) {
    annotationPackages.add(packageGraph.root);
  }

  await generate(annotationPackages);

  if (Args().save.value! && !runFromLocal) {
    final File file = File(path.join(Args().pathUri, argumentsFile));
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsStringSync(arguments.join(' '));
  }

  print(green.wrap(
      '\nff_annotation_route ------ End [${DateTime.now().difference(before)}]'));
}
