import 'package:ff_annotation_route/src/route_info/route_info_base.dart';

class FileInfo {
  FileInfo({this.packageName, this.export});

  final String? packageName;
  final String? export;
  final List<RouteInfoBase> routes = <RouteInfoBase>[];
}
