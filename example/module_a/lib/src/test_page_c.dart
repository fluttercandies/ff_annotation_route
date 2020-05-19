import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://testPageC',
  routeName: 'testPageC',
  description: 'This is test page c in other module.',
)
class TestPageC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('TestPageC'),
      ),
    );
  }
}
