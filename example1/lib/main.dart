import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final FFRouteInformationParser _ffRouteInformationParser =
      FFRouteInformationParser();

  final FFRouterDelegate _ffRouterDelegate = FFRouterDelegate(
      getRouteSettings: getRouteSettings,
      routeWrapper: (FFRouteSettings ffRouteSettings) {
        if (ffRouteSettings.name == Routes.fluttercandiesMainpage ||
            ffRouteSettings.name == Routes.fluttercandiesDemogrouppage.name) {
          return ffRouteSettings;
        }
        return ffRouteSettings.copyWith(
            widget: CommonWidget(
          child: ffRouteSettings.widget,
          page: ffRouteSettings,
        ));
      });
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(
          location: Routes.fluttercandiesMainpage,
        ),
      ),
      routeInformationParser: kIsWeb ? _ffRouteInformationParser : null,
      routerDelegate: _ffRouterDelegate,
    );
  }
}

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    this.child,
    this.page,
  });
  final Widget child;
  final FFRouteSettings page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          page.routeName,
        ),
      ),
      body: child,
    );
  }
}
