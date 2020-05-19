import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import '../example_route.dart';

@FFRoute(
  name: 'fluttercandies://mainpage',
  routeName: 'MainPage',
)
class MainPage extends StatelessWidget {
  MainPage()
      : routes = routeNames.toList()
          ..remove('fluttercandies://mainpage')
          /// just demo
          ..remove('fluttercandies://picswiper');
  final List<String> routes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('ff_annotation_route'),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20.0),
              child: Text(routeNames[index]),
            ),
            onTap: () {
              Navigator.pushNamed<dynamic>(context, routes[index],
                  arguments: <String, dynamic>{
                    'argumentNames': 'This is test for argumentNames',
                  });
            },
          );
        },
        itemCount: routes.length,
      ),
    );
  }
}
