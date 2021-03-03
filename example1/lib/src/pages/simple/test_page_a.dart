import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: '/testPageA',
  routeName: 'testPageA',
  description: 'This is test page A.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class TestPageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageA'),
    );
  }
}
