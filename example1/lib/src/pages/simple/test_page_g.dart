import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: '/testPageG',
  routeName: 'testPageG',
  description: 'Pop with result test page(push from TestPageC)',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 3,
  },
)
class TestPageG extends StatelessWidget {
  const TestPageG({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextButton(
          onPressed: () {
            FFRouterDelegate.of(context).pop('pop result');
          },
          child: const Text('pop'),
        ),
      ],
    );
  }
}
