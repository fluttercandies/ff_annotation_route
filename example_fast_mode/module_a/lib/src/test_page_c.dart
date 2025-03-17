import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageC',
  routeName: 'testPageC',
  description: 'This is test page c in other module.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 2,
  },
)
class TestPageC extends StatelessWidget {
  const TestPageC({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageC I\'m in module_a'),
    );
  }
}
