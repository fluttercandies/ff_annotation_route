import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageD_moduleA',
  routeName: 'testPageA',
  description: 'This is test page D. in module a',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class TestPageD extends StatelessWidget {
  const TestPageD({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageA'),
    );
  }
}
