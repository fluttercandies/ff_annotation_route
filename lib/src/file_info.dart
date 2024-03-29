//import 'package:analyzer/dart/element/element.dart';
import 'package:ff_annotation_route/src/route_info/route_info_base.dart';

class FileInfo {
  FileInfo({
    required this.packageName,
    required this.export,
  });

  final String packageName;
  final String export;
  final List<RouteInfoBase> routes = <RouteInfoBase>[];

  // store argumentImports and FFArgumentImport
  static Set<String> imports = <String>{};
}
