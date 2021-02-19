import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageG',
  routeName: 'testPageG',
  description: 'Pop with result test page(push from TestPageC)',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 3,
  },
)
class TestPageG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            FFRouterDelegate.of(context).pop('pop result');
          },
          child: const Text('pop'),
        ),
      ],
    );
  }
}
