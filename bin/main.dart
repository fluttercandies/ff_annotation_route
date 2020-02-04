import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:ff_annotation_route/src/package_graph.dart';

void main(List<String> arguments) {
  final before = DateTime.now();
  print('ff_annotation_route ------ Start');

  PackageGraph packageGraph;
  final path = arguments.firstWhere(
    (x) => x.contains('path='),
    orElse: () => null,
  );

  if (path != null) {
    packageGraph = PackageGraph.forPath(path.replaceAll('path=', ''));
  } else {
    packageGraph = PackageGraph.forThisPackage();
  }

  final generateRouteNamesS = arguments.firstWhere(
    (x) => x.contains('generateRouteNames='),
    orElse: () => null,
  );
  bool generateRouteNames;
  if (generateRouteNamesS != null) {
    generateRouteNames =
        generateRouteNamesS.replaceAll('generateRouteNames=', '') == 'true';
  } else {
    generateRouteNames = false;
  }

  final generateRouteConstantsS = arguments.firstWhere(
    (x) => x.contains('generateRouteConstants='),
    orElse: () => null,
  );
  bool generateRouteConstants;
  if (generateRouteConstantsS != null) {
    generateRouteConstants =
        generateRouteConstantsS.replaceAll('generateRouteConstants=', '') ==
            'true';
  } else {
    generateRouteConstants = false;
  }

  final modeS = arguments.firstWhere(
    (x) => x.contains('mode='),
    orElse: () => null,
  );
  int mode;
  if (modeS != null) {
    mode = int.tryParse(
      modeS.replaceAll('mode=', '') ?? 0,
    );
  } else {
    mode = 0;
  }

  bool routeSettingsNoArguments;
  if (mode == 1) {
    var routeSettingsNoArgumentsS = arguments.firstWhere(
      (x) => x.contains('routeSettingsNoArguments='),
      orElse: () => null,
    );
    if (routeSettingsNoArgumentsS != null) {
      routeSettingsNoArguments = routeSettingsNoArgumentsS.replaceAll(
              'routeSettingsNoArguments=', '') ==
          'true';
    } else {
      routeSettingsNoArguments = false;
    }
  } else {
    routeSettingsNoArguments = false;
  }

  //only check path and import ff_annotation_route
  final annotationPackages = packageGraph.allPackages.values
      .where((x) =>
          x.dependencyType == DependencyType.path &&
          (x.dependencies.firstWhere(
                (dep) => dep?.name == 'ff_annotation_route',
                orElse: () => null,
              ) !=
              null))
      .toList();

  final rootAnnotationRouteEnable =
      annotationPackages.contains(packageGraph.root);
  if (!rootAnnotationRouteEnable) {
    annotationPackages.add(packageGraph.root);
  }

  generate(
    annotationPackages,
    generateRouteNames: generateRouteNames,
    generateRouteConstants: generateRouteConstants,
    mode: mode,
    routeSettingsNoArguments: routeSettingsNoArguments,
    rootAnnotationRouteEnable: rootAnnotationRouteEnable,
  );

  var diff = DateTime.now().difference(before);
  print('\nff_annotation_route ------ End [$diff]');
}
