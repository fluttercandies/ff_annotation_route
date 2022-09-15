import 'dart:io' as io;
import 'dart:io';

import 'package:build_runner_core/build_runner_core.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/arg/arg_parser.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart';

const String argumentsFile = 'ff_annotation_route_commands';
const String debugCommands =
    '--path example/ --super-arguments --null-safety --no-arguments-case-sensitive --no-fast-mode';

Future<void> main(List<String> arguments) async {
  //debug
  //arguments = debugCommands.split(' ');
  bool runFromLocal = false;
  if (arguments.isEmpty) {
    final io.File file = io.File(join('./', argumentsFile));
    if (file.existsSync()) {
      final String content = file.readAsStringSync();
      // if (content.contains(',')) {
      //   //old style
      //   arguments = content.split(',');
      // } else {
      arguments = content.split(' ');
      //}
      runFromLocal = true;
    }
  }

  //keep old work
  // for (int i = 0; i < arguments.length; i++) {
  //   if (arguments[i] == '-rc') {
  //     arguments[i] = '--route-constants';
  //   } else if (arguments[i] == '-rh') {
  //     arguments[i] = '--route-helper';
  //   } else if (arguments[i] == '-rn') {
  //     arguments[i] = '--route-names';
  //   } else if (arguments[i] == '-rfo') {
  //     arguments[i] = '--routes-file-output';
  //   } else if (arguments[i] == '-na') {
  //     arguments[i] = '--no-arguments';
  //   }
  // }

  // arguments = arguments.toList();

  // arguments.remove('--route-helper');
  // arguments.remove('--no-is-initial-route');
  // arguments.remove('--no-arguments');
  // arguments.remove('--route-constants');
  // arguments.remove('--route-names');

  parseArgs(arguments);

  if (arguments.isEmpty || Args().help.value!) {
    print(green.wrap(parser.usage));
    return;
  }

  final DateTime before = DateTime.now();

  print(green.wrap('\nff_annotation_route ------ Start'));

  final PackageGraph packageGraph =
      await PackageGraph.forPath(Args().path.value!);

  // Only check path which imports ff_annotation_route_core or ff_annotation_route_library
  final List<PackageNode> annotationPackages =
      packageGraph.allPackages.values.where(
    (PackageNode x) {
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
    final File file = File(join('./', argumentsFile));
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsStringSync(arguments.join(' '));
  }

  final Duration diff = DateTime.now().difference(before);
  print(green.wrap('\nff_annotation_route ------ End [$diff]'));
}
