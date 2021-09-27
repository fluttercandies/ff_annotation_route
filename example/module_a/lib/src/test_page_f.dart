import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageF_moduleA',
  routeName: 'testPageA',
  description: 'This is test page F. in module a',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class TestPageF extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageA'),
    );
  }
}
