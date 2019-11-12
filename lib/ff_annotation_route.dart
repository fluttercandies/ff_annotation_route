library ff_annotation_route;

export 'src/ff_route.dart';

import 'src/package_graph.dart';
import 'src/route_generator.dart';

void generate(
  List<PackageNode> annotationPackages, {
  bool generateRouteNames = false,
  int mode = 0,
  bool routeSettingsNoArguments = false,
  bool rootAnnotationRouteEnable = true,
}) {
  RouteGenerator root;
  List<RouteGenerator> nodes = List<RouteGenerator>();
  for (final annotationPackage in annotationPackages) {
    final routeGenerator = RouteGenerator(annotationPackage);
    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      routeGenerator.getLib();
      routeGenerator.scanLib();
      if (routeGenerator.hasAnnotationRoute) {
        routeGenerator.generateFile();
        nodes.add(routeGenerator);
      }
    }
  }
  root?.getLib();
  if (rootAnnotationRouteEnable) {
    root?.scanLib();
  }
  root?.generateFile(
    nodes: nodes,
    generateRouteNames: generateRouteNames,
  );
  root?.generateHelperFile(
    nodes: nodes,
    routeSettingsNoArguments: routeSettingsNoArguments,
    mode: mode,
  );
}
