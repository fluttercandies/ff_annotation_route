import 'package:example_go_router/example_go_router_route.dart';
import 'package:example_go_router/src/router/binding.dart';
import 'package:example_go_router/src/router/interceptors/interface.dart';
import 'package:example_go_router/src/router/interceptors/login_interceptor.dart';
import 'package:example_go_router/src/router/interceptors/permission_interceptor.dart';
import 'package:example_go_router/src/router/router.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  ExternalLinkBinding();
  // register services for interceptors
  // final GetIt getIt = GetIt.instance;
  registerInterceptors();

  // adding global interceptors
  RouteInterceptorManager().addGlobalInterceptors([
    const GlobalLoginInterceptor(),
    const GlobalPermissionInterceptor(),
  ]);

  // using routeInterceptors
  RouteInterceptorManager().addAllRouteInterceptors(routeInterceptors);

  // or using routeInterceptorTypes
  RouteInterceptorManager().addAllRouteInterceptors(
    routeInterceptorTypes.map(
      (String key, List<Type> value) =>
          MapEntry<String, List<RouteInterceptor>>(
            key,
            value.map<RouteInterceptor>((Type type) {
              final GetIt getIt = GetIt.instance;
              return getIt.get(type: type);
            }).toList(),
          ),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: appGoRouter,
    );
  }
}
