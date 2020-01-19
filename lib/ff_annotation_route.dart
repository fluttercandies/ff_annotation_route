library ff_annotation_route;

export 'src/ff_route.dart';

import 'src/format.dart';
import 'src/package_graph.dart';
import 'src/route_generator.dart';

void generate(
  List<PackageNode> annotationPackages, {
  bool generateRouteNames = false,
  bool generateRouteConstants = false,
  int mode = 0,
  bool routeSettingsNoArguments = false,
  bool rootAnnotationRouteEnable = true,
}) {
  RouteGenerator root;
  final nodes = <RouteGenerator>[];
  for (final annotationPackage in annotationPackages) {
    final routeGenerator = RouteGenerator(annotationPackage);
    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      routeGenerator.getLib();
      routeGenerator.scanLib();
      if (routeGenerator.hasAnnotationRoute) {
        final file = routeGenerator.generateFile();
        formatFile(file);
        nodes.add(routeGenerator);
      }
    }
  }
  root?.getLib();
  if (rootAnnotationRouteEnable) {
    root?.scanLib();
  }
  final routeFile = root?.generateFile(
    nodes: nodes,
    generateRouteNames: generateRouteNames,
    generateRouteConstants: generateRouteConstants,
  );
  final helperFile = root?.generateHelperFile(
    nodes: nodes,
    routeSettingsNoArguments: routeSettingsNoArguments,
    mode: mode,
  );

  formatFile(routeFile);
  if (routeFile != null) formatFile(helperFile);
}
