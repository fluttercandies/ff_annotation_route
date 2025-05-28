import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport('as module_a')
import 'package:module_a/src/mode/mode.dart';

@FFRoute(
  name: "flutterCandies://testPage' \"B_module_a",
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
    Key? key,
    this.argument,
    this.title = 'dddd',
  }) : super(key: key);

  //const TestPageB._(this.argument);
  final TestMode? argument;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('TestPageB  $argument'),
    );
  }
}
