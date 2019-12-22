import 'route_info.dart';

class FileInfo {
  final String packageName;
  final String export;
  final List<RouteInfo> routes = <RouteInfo>[];

  FileInfo({this.packageName, this.export});
}
