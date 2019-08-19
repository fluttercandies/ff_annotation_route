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

  var checkEnableS = arguments.firstWhere((x) => x.contains("checkEnable="),
      orElse: () => null);
  bool checkEnable = false;
  if (checkEnableS != null) {
    checkEnable = checkEnableS.replaceAll("checkEnable=", "") == "true";
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

  List<PackageNode> annotationPackages = List<PackageNode>();
  //only check path
  var packages = packageGraph.allPackages.values
      .where((x) => x.dependencyType == DependencyType.path);
  annotationPackages.addAll(packages);
  bool rootAnnotationRouteEnable = true;
  if (checkEnable) {
    for (var package in packages) {
      var map = pubspecForPath(package.path);
      var enable = map["annotation_route_enable"] ?? false;
      if (!package.isRoot && !enable) {
        annotationPackages.remove(package);
      }
      if (package.isRoot) {
        rootAnnotationRouteEnable = enable;
      }
    }
  }

  generate(annotationPackages,
      generateRouteNames: generateRouteNames,
      mode: mode,
      routeSettingsNoArguments: routeSettingsNoArguments,
      rootAnnotationRouteEnable: rootAnnotationRouteEnable);

  print("");
  print("ff_annotation_route------------------ end");
}
