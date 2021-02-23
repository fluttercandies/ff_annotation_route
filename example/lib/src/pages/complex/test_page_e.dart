import 'package:example/example_routes.dart';
@FFArgumentImport('hide TestMode2')
import 'package:example/src/model/test_model.dart';
@FFArgumentImport()
import 'package:example/src/model/test_model1.dart' hide TestMode3;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageE',
  routeName: 'testPageE',
  description: 'Show how to push new page with arguments(class)',
  // argumentImports are still work for some cases which you can't use @FFArgumentImport()
  // argumentImports: <String>[
  //   'import \'package:example/src/model/test_model.dart\';',
  //   'import \'package:example/src/model/test_model1.dart\';',
  // ],
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class TestPageE extends StatelessWidget {
  const TestPageE({
    this.testMode = const TestMode(
      id: 2,
      isTest: false,
    ),
    this.testMode1,
  });
  factory TestPageE.test() => TestPageE(
        testMode: TestMode.test(),
      );

  factory TestPageE.requiredC({@required TestMode testMode}) => TestPageE(
        testMode: testMode,
      );

  final TestMode testMode;
  final TestMode1 testMode1;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Text('TestPageE $testMode'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.flutterCandiesTestPageE.name,
                arguments: Routes.flutterCandiesTestPageE.test());
          },
          child: const Text(
            'TestPageE.deafult()',
          ),
        ),
        FlatButton(
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
