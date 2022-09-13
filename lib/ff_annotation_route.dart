library ff_annotation_route;

import 'package:build_runner_core/build_runner_core.dart';

import 'src/arg/args.dart';
import 'src/route_generator.dart';

Future<void> generate(List<PackageNode> annotationPackages) async {
  RouteGenerator? root;
  final List<RouteGenerator> nodes = <RouteGenerator>[];
  for (int i = 0; i < annotationPackages.length; i++) {
    final PackageNode annotationPackage = annotationPackages[i];
    final RouteGenerator routeGenerator = RouteGenerator(
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
    (RouteGenerator a, RouteGenerator b) =>
        a.packageNode.name.compareTo(b.packageNode.name),
  );
  root?.getLib();

  await root?.scanLib(Args().outputPath);

  root?.generateFile(
    nodes: nodes,
  );
}
