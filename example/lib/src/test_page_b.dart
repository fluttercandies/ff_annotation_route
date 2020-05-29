import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageB',
  routeName: 'testPageB',
  description: 'This is test page B.',
  argumentNames: <String>['argument'],
  argumentTypes: <String>['String'],
  exts: <String, dynamic>{
    'test': 1,
    'test1': 'string',
  },
)
class TestPageB extends StatelessWidget {
  const TestPageB({this.argument});
  final String argument;
  @override
  Widget build(BuildContext context) {
    print(argument);
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('TestPageB'),
      ),
    );
  }
}
