import 'package:example/src/model/test_model.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageE',
  routeName: 'testPageE',
  description: 'This is test page E.',
  argumentImports: 'import \'package:example/src/model/test_model.dart\';',
)
class TestPageE extends StatelessWidget {
  const TestPageE({
    this.testMode = const TestMode(
      id: 2,
      isTest: false,
    ),
  });
  factory TestPageE.deafult() => TestPageE(
        testMode: TestMode.deafult(),
      );

  factory TestPageE.required({@required TestMode testMode}) => TestPageE(
        testMode: testMode,
      );

  final TestMode testMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('TestPageE'),
      ),
    );
  }
}
