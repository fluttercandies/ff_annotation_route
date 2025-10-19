import 'package:example_go_router/src/router/interceptors/login_interceptor.dart';
import 'package:example_go_router/src/router/interceptors/permission_interceptor.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:get_it/get_it.dart';

abstract class ILoginInterceptor extends RouteInterceptor {
  const ILoginInterceptor();
}

abstract class IPermissionInterceptor extends RouteInterceptor {
  const IPermissionInterceptor();
}

void registerInterceptors() {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<ILoginInterceptor>(LoginInterceptor());
  getIt.registerSingleton<IPermissionInterceptor>(PermissionInterceptor());
}
