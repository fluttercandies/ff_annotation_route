import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: "flutterCandies://testPage\' \"B",
  routeName: 'testPageB ' '',
  description: 'This is test \' page B.',
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
