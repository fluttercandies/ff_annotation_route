import 'package:analyzer/dart/element/type.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

class FFRouteInterceptor extends RouteInterceptor {
  FFRouteInterceptor({this.className, this.dartType});
  // fast mode
  final String? className;

  // none fast mode
  final DartType? dartType;

  @override
  Future<RouteInterceptResult> intercept(String routeName,
      {Object? arguments}) {
    throw UnimplementedError();
  }
}
