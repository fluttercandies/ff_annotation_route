library ff_annotation_route;

export 'src/ff_route.dart';

import 'package:ff_annotation_route/src/utils/format.dart';

import 'src/package_graph.dart';
import 'src/route_generator.dart';

void generate(
  List<PackageNode> annotationPackages, {
  bool generateRouteNames = false,
  bool generateRouteConstants = false,
  bool generateRouteHelper = false,
  bool routeSettingsNoArguments = false,
  bool rootAnnotationRouteEnable = true,
  bool isPackage = false,
  bool routeSettingsNoIsInitialRoute = false,
}) {
  RouteGenerator root;
  final nodes = <RouteGenerator>[];
  for (final annotationPackage in annotationPackages) {
    final routeGenerator = RouteGenerator(
      annotationPackage,
      annotationPackage.isRoot && !isPackage,
    );
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
    generateRouteHelper: generateRouteHelper,
    routeSettingsNoIsInitialRoute: routeSettingsNoIsInitialRoute,
  );

  formatFile(routeFile);
  if (routeFile != null) formatFile(helperFile);
}
