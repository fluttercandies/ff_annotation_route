import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/package_graph.dart';

main(List<String> arguments) {
  print("ff_annotation_route------------------ start");

  PackageGraph packageGraph;
  var path =
      arguments.firstWhere((x) => x.contains("path="), orElse: () => null);

  if (path != null) {
    packageGraph = PackageGraph.forPath(path.replaceAll("path=", ""));
  } else {
    packageGraph = PackageGraph.forThisPackage();
  }

  var generateRouteNamesS = arguments
      .firstWhere((x) => x.contains("generateRouteNames="), orElse: () => null);
  bool generateRouteNames = false;
  if (generateRouteNamesS != null) {
    generateRouteNames =
        generateRouteNamesS.replaceAll("generateRouteNames=", "") == "true";
  }
 
  var modeS =
      arguments.firstWhere((x) => x.contains("mode="), orElse: () => null);
  int mode = 0;
  if (modeS != null) {
    mode = int.tryParse(
      modeS.replaceAll("mode=", "") ?? 0,
    );
  }
 
  bool routeSettingsNoArguments = false;
  if (mode == 1) {
    var routeSettingsNoArgumentsS = arguments.firstWhere(
        (x) => x.contains("routeSettingsNoArguments="),
        orElse: () => null);
    if (routeSettingsNoArgumentsS != null) {
      routeSettingsNoArguments = routeSettingsNoArgumentsS.replaceAll(
              "routeSettingsNoArguments=", "") ==
          "true";
    }
  }

  //only check path and import ff_annotation_route
  List<PackageNode> annotationPackages = packageGraph.allPackages.values
      .where((x) =>
          x.dependencyType == DependencyType.path &&
          (x.dependencies.firstWhere((dep) => dep.name == "ff_annotation_route",
                  orElse: () => null) !=
              null))
      .toList();

  bool rootAnnotationRouteEnable =
      annotationPackages.contains(packageGraph.root);
  if (!rootAnnotationRouteEnable) {
    annotationPackages.add(packageGraph.root);
  }

  generate(annotationPackages,
      generateRouteNames: generateRouteNames,
      mode: mode,
      routeSettingsNoArguments: routeSettingsNoArguments,
      rootAnnotationRouteEnable: rootAnnotationRouteEnable);

  print("");
  print("ff_annotation_route------------------ end");
}
