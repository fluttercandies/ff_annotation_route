import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

import 'mode/mode.dart';

@FFRoute(
  name: "flutterCandies://testPage\' \"B_module_a",
  routeName: 'testPageB ' '',
  description: 'This is test \' page B. in module a',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 1,
  },
  showStatusBar: true,
  pageRouteType: PageRouteType.material,
)
class TestPageB extends StatelessWidget {
  const TestPageB({
    this.argument,
  });
  //const TestPageB._(this.argument);
  final TestMode? argument;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('TestPageB  $argument'),
    );
  }
}
