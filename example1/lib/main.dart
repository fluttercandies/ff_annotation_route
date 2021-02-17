import 'dart:convert';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() {
  FFConvert.convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    // you can convert your data base on your case.
    return json.decode(value.toString()) as T;
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FFRouteInformationParser _ffRouteInformationParser =
      FFRouteInformationParser();

  final FFRouterDelegate _ffRouterDelegate = FFRouterDelegate(
      getRouteSettings: getRouteSettings,
      pageWrapper: (FFPage ffPage) {
        if (ffPage.name == Routes.fluttercandiesMainpage ||
            ffPage.name == Routes.fluttercandiesDemogrouppage.name) {
          // define key if this page is unique
          // The key associated with this page.
          //
          // This key will be used for comparing pages in [canUpdate].
          return ffPage.copyWith(
            key: ValueKey<String>('${ffPage.name}-${ffPage.arguments}'),
          );
        }
        return ffPage.copyWith(
            widget: CommonWidget(
          child: ffPage.widget,
          page: ffPage,
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
  final FFPage page;

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
