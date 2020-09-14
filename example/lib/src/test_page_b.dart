import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: "flutterCandies://testPage\' \"B",
  routeName: 'testPageB ' '',
  description: 'This is test \' page B.',
  exts: <String, dynamic>{
    'test': 1,
    'test1': 'string',
  },
  showStatusBar: true,
  pageRouteType: PageRouteType.material,
)
class TestPageB extends StatelessWidget {
  const TestPageB({this.argument});
  //const TestPageB._(this.argument);
  final String argument;
  @override
  Widget build(BuildContext context) {
    print(argument);
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('TestPageB'),
      ),
    );
  }
}
