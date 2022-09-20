library ff_annotation_route;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:ff_annotation_route/src/route_generator/fast_route_generator.dart';
import 'package:ff_annotation_route/src/route_generator/route_generator.dart';
import 'package:ff_annotation_route/src/route_generator/route_generator_base.dart';
import 'package:ff_annotation_route/src/routes_file_generator.dart';
import 'package:ff_annotation_route/src/utils/git_package_handler.dart';
import 'src/arg/args.dart';

Future<void> generate(List<PackageNode> annotationPackages) async {
  RouteGeneratorBase? root;
  final List<RouteGeneratorBase> nodes = <RouteGeneratorBase>[];
  final List<String> libPaths = <String>[];
  for (final PackageNode annotationPackage in annotationPackages) {
    final RouteGeneratorBase routeGenerator = Args().isFastMode
        ? FastRouteGenerator(
            packageName: annotationPackage.name,
            packagePath: annotationPackage.path,
            isRoot: annotationPackage.isRoot && !Args().isPackage,
          )
        : RouteGenerator(
            packageName: annotationPackage.name,
            packagePath: annotationPackage.path,
            isRoot: annotationPackage.isRoot && !Args().isPackage,
          );

    final String? libPath = routeGenerator.lib?.path;
    if (libPath == null) {
      return;
    }

    libPaths.add(libPath);

    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      nodes.add(routeGenerator);
    }
  }

  AnalysisContextCollection? collection;
  if (!Args().isFastMode) {
    collection = AnalysisContextCollection(
      includedPaths: libPaths,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
  }

  for (final RouteGeneratorBase routeGenerator in nodes.toList()) {
    // remove first
    RoutesFileGenerator.deleteFile(
      packageName: routeGenerator.packageName,
      lib: routeGenerator.lib!,
    );
    // remove first
    routeGenerator.deleteFile();
    await routeGenerator.scanLib(collection: collection);
    if (routeGenerator.hasAnnotationRoute) {
      routeGenerator.generateFile();
    } else {
      nodes.remove(routeGenerator);
    }
  }

  nodes.sort(
    (RouteGeneratorBase a, RouteGeneratorBase b) =>
        a.packageName.compareTo(b.packageName),
  );

  if (root != null) {
    // remove first
    RoutesFileGenerator.deleteFile(
      packageName: root.packageName,
      lib: root.lib!,
    );
    // remove first
    root.deleteFile();
    await root.scanLib(output: Args().outputPath, collection: collection);

    root.generateFile(nodes: nodes);
  }

  GitPackageHandler().deleteGitPackageFromDartTool();
}
