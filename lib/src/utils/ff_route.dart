import 'package:analyzer/dart/element/type.dart';
import 'package:ff_annotation_route/src/arg/args.dart';
import 'package:ff_annotation_route/src/utils/route_interceptor.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

/// internal use only
class GeneratedFFRoute extends FFRoute {
  GeneratedFFRoute({
    required String name,
    super.showStatusBar = true,
    super.routeName = '',
    super.pageRouteType,
    super.description = '',
    super.exts,
    super.argumentImports,
    super.codes,
    this.interceptors,
    this.interceptorTypeStrings,
  }) : super(
         name: Args().isNameCaseSensitive ? name : name.toLowerCase(),
         interceptors: interceptors,
       );

  @override
  // ignore: overridden_fields
  final List<FFRouteInterceptor>? interceptors;

  final List<InterceptorType>? interceptorTypeStrings;
}

class InterceptorType {
  InterceptorType({this.className, this.dartType});

  // fast mode
  final String? className;

  // none fast mode
  final DartType? dartType;
}
