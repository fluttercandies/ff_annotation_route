// ignore_for_file: unused_shown_name

import 'package:example/example_routes.dart';
import 'package:example/src/model/test_model.dart' show TestMode;
import 'package:example/src/model/test_model1.dart'
    show TestMode4, TestMode1, TestMode2
    hide TestMode3;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageE',
  routeName: 'testPageE',
  description: 'Show how to push new page with arguments(class)',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class TestPageE extends StatelessWidget {
  const TestPageE({
    super.key,
    this.testMode = const TestMode(
      id: 2,
      isTest: false,
    ),
    this.testMode1,
  });

  factory TestPageE.test() => TestPageE(
        testMode: TestMode.test(),
      );

  factory TestPageE.requiredC({required TestMode? testMode}) => TestPageE(
        testMode: testMode,
      );

  final TestMode? testMode;
  final TestMode1? testMode1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Text('TestPageE $testMode'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.flutterCandiesTestPageE.name,
                arguments: Routes.flutterCandiesTestPageE.test());
          },
          child: const Text(
            'TestPageE.deafult()',
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.flutterCandiesTestPageE.name,
              arguments: Routes.flutterCandiesTestPageE.requiredC(
                testMode: const TestMode(
                  id: 100,
                  isTest: true,
                ),
              ),
            );
          },
          child: const Text(
            'TestPageE.required()',
          ),
        ),
      ],
    );
  }
}
