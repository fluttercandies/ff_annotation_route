import 'dart:convert';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() {
  // tool will handle simple types(int,double,bool etc.), but not all of them.
  // in this case, you can override following method,convert the queryParameters base on your case.
  // for example, you can type in web browser
  // http://localhost:64916/#/testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  FFConvert.convert = <T extends Object?>(dynamic value) {
    if (value == null) {
      return null;
    }
    print(T);
    final dynamic output = json.decode(value.toString());
    if (<int>[] is T && output is List<dynamic>) {
      return output.map<int?>((dynamic e) => asT<int>(e)).toList() as T;
    } else if (<String, String>{} is T && output is Map<dynamic, dynamic>) {
      return output.map<String, String>((dynamic key, dynamic value) =>
          MapEntry<String, String>(key.toString(), value.toString())) as T;
    } else if (const TestMode() is T && output is Map<dynamic, dynamic>) {
      return TestMode.fromJson(output) as T;
    }

    return json.decode(value.toString()) as T?;
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FFRouteInformationParser _ffRouteInformationParser =
      FFRouteInformationParser();

  final FFRouterDelegate _ffRouterDelegate = FFRouterDelegate(
    getRouteSettings: getRouteSettings,
    notFoundPageBuilder: () => Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('not find page'),
      ),
    ),
    pageWrapper: <T>(FFPage<T> ffPage) {
      if (ffPage.name == Routes.root ||
          ffPage.name == Routes.demogrouppage.name) {
        return ffPage.copyWith(
            builder: () => CommonWidget(
                  child: ffPage.builder(),
                  routeName: ffPage.routeName,
                ));
      }
      return ffPage;
    },
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // flutter issue https://github.com/flutter/flutter/issues/77143
      // before fix, you can define your initial route to '/'
      // after fix, you can define your initial route as following
      // initialRoute
      // routeInformationProvider: PlatformRouteInformationProvider(
      //   initialRouteInformation: const RouteInformation(
      //     location: Routes.mainpage,
      //   ),
      // ),
      routeInformationParser: _ffRouteInformationParser,
      routerDelegate: _ffRouterDelegate,
    );
  }
}

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    this.child,
    this.routeName,
  });
  final Widget? child;
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          routeName!,
        ),
      ),
      body: child,
    );
  }
}
