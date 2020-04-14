import 'package:example/example_route.dart';
import 'package:example/src/no_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

import 'example_route_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'ff_annotation_route demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [
          FFNavigatorObserver(routeChange: (
            Route newRoute,
            Route oldRoute,
          ) {
            FFRouteSettings newSetting;
            FFRouteSettings oldSetting;

            if (newRoute?.settings is FFRouteSettings) {
              newSetting = newRoute.settings;
            }
            if (oldRoute?.settings is FFRouteSettings) {
              oldSetting = oldRoute.settings;
            }

            if (newSetting?.showStatusBar != oldSetting?.showStatusBar) {
              if (newSetting?.showStatusBar ?? false) {
                SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
              } else {
                SystemChrome.setEnabledSystemUIOverlays([]);
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
              print("route change: ${newSetting?.routeName}");
            }
          })
        ],
        builder: (c, w) {
          ScreenUtil.init(c, width: 750, height: 1334, allowFontScaling: true);
          var data = MediaQuery.of(c);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: w,
          );
        },
        initialRoute: Routes.FLUTTERCANDIES_MAINPAGE,
        onGenerateRoute: (RouteSettings settings) =>
            onGenerateRouteHelper(settings, notFoundFallback: NoRoute()),
      ),
    );
  }
}
