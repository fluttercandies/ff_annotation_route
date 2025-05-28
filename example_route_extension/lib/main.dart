import 'package:example_route_extension/src/interceptors/login_interceptor.dart';
import 'package:example_route_extension/src/interceptors/permission_interceptor.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

import 'example_route_extension_route.dart';
import 'example_route_extension_routes.dart';

void main() {
  RouteInterceptorManager().addGlobalInterceptors([
    const GlobalLoginInterceptor(),
    const GlobalPermissionInterceptor(),
  ]);
  RouteInterceptorManager().addAllRouteInterceptors(routeInterceptors);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesHomePage.name,
      navigatorKey: GlobalNavigator.navigatorKey,
      navigatorObservers: <NavigatorObserver>[ExtendedRouteObserver()],
      onGenerateRoute: (RouteSettings settings) {
        return onGenerateRoute(
          settings: settings,
          getRouteSettings: getRouteSettings,
          notFoundPageBuilder: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('not find page'),
            ),
          ),
        );
      },
    );
  }
}
