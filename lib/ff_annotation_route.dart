library ff_annotation_route;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:ff_annotation_route/src/route_generator/fast_route_generator.dart';
import 'package:ff_annotation_route/src/route_generator/route_generator.dart';
import 'package:ff_annotation_route/src/route_generator/route_generator_base.dart';
import 'package:ff_annotation_route/src/routes_file_generator.dart';

import 'src/arg/args.dart';

Future<void> generate(List<PackageNode> annotationPackages) async {
  RouteGeneratorBase? root;
  final List<RouteGeneratorBase> nodes = <RouteGeneratorBase>[];
  final List<String> libPaths = <String>[];
  for (final PackageNode annotationPackage in annotationPackages) {
    final RouteGeneratorBase routeGenerator = Args().isFastMode
        ? FastRouteGenerator(
            annotationPackage,
            annotationPackage.isRoot && !Args().isPackage,
          )
        : RouteGenerator(
            annotationPackage,
            annotationPackage.isRoot && !Args().isPackage,
          );

    final String? libPath = routeGenerator.getLib();
    if (libPath == null) {
      return;
    }
    libPaths.add(libPath);
    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      nodes.add(routeGenerator);
    }
    // remove first
    RoutesFileGenerator.deleteFile(
      packageNode: routeGenerator.packageNode,
      lib: routeGenerator.lib!,
    );
    // remove first
    routeGenerator.deleteFile();
  }

  AnalysisContextCollection? collection;
  if (!Args().isFastMode) {
    collection = AnalysisContextCollection(
      includedPaths: libPaths,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
  }

  for (final RouteGeneratorBase routeGenerator in nodes.toList()) {
    await routeGenerator.scanLib(collection: collection);
    if (routeGenerator.hasAnnotationRoute) {
      routeGenerator.generateFile();
    } else {
      nodes.remove(routeGenerator);
    }
  }

  nodes.sort(
    (RouteGeneratorBase a, RouteGeneratorBase b) =>
        a.packageNode.name.compareTo(b.packageNode.name),
  );

  await root?.scanLib(output: Args().outputPath, collection: collection);

  root?.generateFile(nodes: nodes);
}
