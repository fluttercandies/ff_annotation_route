import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageC_Copy',
  routeName: 'testPageC',
  description: 'This is test page c has the same name with moudle_a TestPageC.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 2,
  },
)
class TestPageC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestPageC I\'m in module_a'),
    );
  }
}

@FFRoute(
  name: "flutterCandies://testPage\' \"B_Copy",
  routeName: 'testPageB ' '',
  description: 'This is test \' page B. has the same name',
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
  final String? argument;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('TestPageB  $argument'),
    );
  }
}
