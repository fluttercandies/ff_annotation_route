//import 'dart:ui' as ui;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
    name: 'flutterCandies://testPageA',
    routeName: 'testPageA',
    description: 'This is test page A.',
    exts: <String, dynamic>{
      'group': 'Simple',
      'order': 0,
      'test6': TestPageA.dd,
      //'test7': ui.BoxWidthStyle.max,
    },
    codes: <String, String>{
      // only support as code, it should not be a real String, you can use exts instead
      //'test1': TestPageA.dd,
      'test2': 'TestPageA.dd',
      'test3': 'TestPageA.ddd',
      'test4': 'TestPageA()',
      'test5': 'TestPageA.ddd',
      // only support as code, it should not be a real String, you can use exts instead
      //'test6': 'dddd',
    })
class TestPageA extends StatelessWidget {
  static const String dd = 'dddd';
  static bool ddd = false;

  const TestPageA({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageA'),
    );
  }
}
