library ff_annotation_route;

import 'src/package_graph.dart';
import 'src/route_generator.dart';
export 'src/ff_route.dart';

void generate(
  List<PackageNode> annotationPackages, {
  bool generateRouteNames = false,
  bool generateRouteConstants = false,
  bool generateRouteHelper = false,
  bool routeSettingsNoArguments = false,
  bool rootAnnotationRouteEnable = true,
  bool isPackage = false,
  bool routeSettingsNoIsInitialRoute = false,
  String outputPath,
  String routesFileOutputPath,
  String className,
  bool enableSupperArguments = false,
  RegExp constIgnore,
}) {
  RouteGenerator root;
  final List<RouteGenerator> nodes = <RouteGenerator>[];
  for (final PackageNode annotationPackage in annotationPackages) {
    final RouteGenerator routeGenerator = RouteGenerator(
      annotationPackage,
      annotationPackage.isRoot && !isPackage,
    );
    if (routeGenerator.isRoot) {
      root = routeGenerator;
    } else {
      routeGenerator.getLib();
      routeGenerator.scanLib();
      if (routeGenerator.hasAnnotationRoute) {
        //final io.File file =
        routeGenerator.generateFile(className: className);
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
  if (rootAnnotationRouteEnable) {
    root?.scanLib(outputPath);
  }
  root?.generateFile(
    nodes: nodes,
    generateRouteNames: generateRouteNames,
    outputPath: outputPath,
    generateRouteConstants: generateRouteConstants,
    routesFileOutputPath: routesFileOutputPath,
    enableSupperArguments: enableSupperArguments,
    constIgnore: constIgnore,
    className: className,
  );
  root?.generateHelperFile(
    nodes: nodes,
    routeSettingsNoArguments: routeSettingsNoArguments,
    generateRouteHelper: generateRouteHelper,
    routeSettingsNoIsInitialRoute: routeSettingsNoIsInitialRoute,
    outputPath: outputPath,
  );
}
