import 'dart:convert';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() {
  // simple types(int,double,bool etc.) are handled by asT method, but not all of them.
  // in this case, you can override following method,convert the queryParameters base on your case.
  // for example, you can type in web browser
  // http://localhost:64916/#flutterCandies://testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  FFConvert.convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    print(T);
    final dynamic output = json.decode(value.toString());
    if (<int>[] is T && output is List<dynamic>) {
      return output.map<int>((dynamic e) => asT<int>(e)).toList() as T;
    } else if (<String, String>{} is T && output is Map<dynamic, dynamic>) {
      return output.map<String, String>((dynamic key, dynamic value) =>
          MapEntry<String, String>(key.toString(), value.toString())) as T;
    } else if (const TestMode() is T && output is Map<dynamic, dynamic>) {
      return TestMode.fromJson(output) as T;
    }

    return json.decode(value.toString()) as T;
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FFRouteInformationParser _ffRouteInformationParser =
      FFRouteInformationParser();

  final FFRouterDelegate _ffRouterDelegate = FFRouterDelegate(
      getRouteSettings: getRouteSettings,
      pageWrapper: <T>(FFPage<T> ffPage) {
        return ffPage.copyWith(
          widget: ffPage.name == Routes.fluttercandiesMainpage ||
                  ffPage.name == Routes.fluttercandiesDemogrouppage.name
              ? ffPage.widget
              : CommonWidget(
                  child: ffPage.widget,
                  routeName: ffPage.routeName,
                ),
        );
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
    this.routeName,
  });
  final Widget child;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          routeName,
        ),
      ),
      body: child,
    );
  }
}
