import 'route_info.dart';

class FileInfo {
  FileInfo({this.packageName, this.export});

  final String? packageName;
  final String? export;
  final List<RouteInfo> routes = <RouteInfo>[];
}
