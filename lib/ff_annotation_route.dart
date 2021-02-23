library ff_annotation_route;

import 'src/arg/args.dart';
import 'src/package_graph.dart';
import 'src/route_generator.dart';
export 'src/route_generator.dart';

void generate(List<PackageNode> annotationPackages) {
  RouteGenerator root;
  final List<RouteGenerator> nodes = <RouteGenerator>[];
  for (final PackageNode annotationPackage in annotationPackages) {
    final RouteGenerator routeGenerator = RouteGenerator(
      annotationPackage,
      annotationPackage.isRoot && !Args().isPackage,
    );
    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      routeGenerator.getLib();
      routeGenerator.scanLib();
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

  root?.scanLib(Args().outputPath);

  root?.generateFile(
    nodes: nodes,
  );
}
