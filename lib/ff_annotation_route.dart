library ff_annotation_route;

import 'src/package_graph.dart';
import 'src/route_generator.dart';
export 'src/arg/arg.dart';
export 'src/arg/arg_parser.dart';

export 'src/arg/const_ignore.dart';
export 'src/arg/git.dart';
export 'src/arg/help.dart';
export 'src/arg/output.dart';
export 'src/arg/package.dart';
export 'src/arg/path.dart';
export 'src/arg/route_constants.dart';
export 'src/arg/route_helper.dart';
export 'src/arg/route_names.dart';
export 'src/arg/routes_file_output.dart';
export 'src/arg/save.dart';
export 'src/arg/settings_no_arguments.dart';
export 'src/arg/settings_no_is_initial_route.dart';
export 'src/arg/super_arguments.dart';
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
  );
  root?.generateHelperFile(
    nodes: nodes,
    routeSettingsNoArguments: routeSettingsNoArguments,
    generateRouteHelper: generateRouteHelper,
    routeSettingsNoIsInitialRoute: routeSettingsNoIsInitialRoute,
    outputPath: outputPath,
  );
}
