import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'example_route.dart';
import 'example_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        return onGenerateRoute(
          settings: settings,
          getRouteSettings: getRouteSettings,
          routeWrapper: (FFRouteSettings ffRouteSettings) {
            if (ffRouteSettings.name == Routes.fluttercandiesMainpage ||
                ffRouteSettings.name ==
                    Routes.fluttercandiesDemogrouppage.name) {
              return ffRouteSettings;
            }
            return ffRouteSettings.copyWith(
                widget: CommonWidget(
              child: ffRouteSettings.widget,
              page: ffRouteSettings,
            ));
          },
        );
      },
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
