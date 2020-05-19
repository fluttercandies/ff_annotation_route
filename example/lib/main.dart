import 'package:example/example_route.dart';
import 'package:example/src/no_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'example_route_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ff_annotation_route demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[
        FFNavigatorObserver(routeChange: (
          Route<dynamic> newRoute,
          Route<dynamic> oldRoute,
        ) {
          FFRouteSettings newSetting;
          FFRouteSettings oldSetting;

          if (newRoute?.settings is FFRouteSettings) {
            newSetting = newRoute.settings as FFRouteSettings;
          }
          if (oldRoute?.settings is FFRouteSettings) {
            oldSetting = oldRoute.settings as FFRouteSettings;
          }

          if (newSetting?.showStatusBar != oldSetting?.showStatusBar) {
            if (newSetting?.showStatusBar ?? false) {
              SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
            } else {
              SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
            }
          }

          if (newRoute is PageRoute &&
              (
                  //first page
                  oldRoute == null ||
                      //exclude PopupRoute ect
                      oldRoute is PageRoute) &&
              newSetting?.routeName != null) {
            //you can track page here
            print('route change: ${newSetting?.routeName}');
          }
        })
      ],
      initialRoute: Routes.FLUTTERCANDIES_MAINPAGE,
      onGenerateRoute: (RouteSettings settings) =>
          onGenerateRouteHelper(settings, notFoundFallback: NoRoute()),
    );
  }
}
