library ff_annotation_route;

import 'package:build_runner_core/build_runner_core.dart';
import 'package:ff_annotation_route/src/route_generator/fast_route_generator.dart';
import 'package:ff_annotation_route/src/route_generator/route_generator.dart';
import 'package:ff_annotation_route/src/route_generator/route_generator_base.dart';

import 'src/arg/args.dart';

Future<void> generate(List<PackageNode> annotationPackages) async {
  RouteGeneratorBase? root;
  final List<RouteGeneratorBase> nodes = <RouteGeneratorBase>[];
  for (int i = 0; i < annotationPackages.length; i++) {
    final PackageNode annotationPackage = annotationPackages[i];
    final RouteGeneratorBase routeGenerator = Args().isFastMode
        ? FastRouteGenerator(
            annotationPackage,
            annotationPackage.isRoot && !Args().isPackage,
          )
        : RouteGenerator(
            annotationPackage,
            annotationPackage.isRoot && !Args().isPackage,
          );
    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      routeGenerator.getLib();
      await routeGenerator.scanLib();
      if (routeGenerator.hasAnnotationRoute) {
        //final io.File file =
        routeGenerator.generateFile();
        //formatFile(file);
        nodes.add(routeGenerator);
      }
    }
  }

  nodes.sort(
    (RouteGeneratorBase a, RouteGeneratorBase b) =>
        a.packageNode.name.compareTo(b.packageNode.name),
  );
  root?.getLib();

  await root?.scanLib(Args().outputPath);

  root?.generateFile(
    nodes: nodes,
  );
}
