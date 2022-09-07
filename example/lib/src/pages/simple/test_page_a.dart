import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
    name: 'flutterCandies://testPageA',
    routeName: 'testPageA',
    description: 'This is test page A.',
    exts: <String, dynamic>{
      'group': 'Simple',
      'order': 0,
    },
    codes: <String, String>{
      'test1': TestPageA.dd,
      'test2': 'TestPageA.dd',
      'test3': 'TestPageA.ddd',
      'test4': 'TestPageA()',
    })
class TestPageA extends StatelessWidget {
  static const String dd = 'dddd';
  static bool ddd = false;
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageA'),
    );
  }
}
