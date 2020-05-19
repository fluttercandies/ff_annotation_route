import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://testPageA',
  routeName: 'testPageA',
  description: 'This is test page A.',
)
class TestPageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('TestPageA'),
      ),
    );
  }
}
