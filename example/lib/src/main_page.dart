import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import '../example_route.dart';

@FFRoute(
  name: "fluttercandies://mainpage",
  routeName: "MainPage",
)
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("ff_annotation_route"),
      ),
      body: ListView.builder(
        itemBuilder: (c, index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20.0),
              child: Text(routeNames[index]),
            ),
            onTap: () {
              Navigator.pushNamed(context, routeNames[index], arguments: {
                "url": "https://photo.tuchong.com/4870004/f/298584322.jpg"
              });
            },
          );
        },
        itemCount: routeNames.length,
      ),
    );
  }
}
