import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
@FFArgumentImport()
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://testPageCC',
  routeName: 'testPageCC',
  description: 'This is test page CC.',
)
class TestPageCC extends StatelessWidget {
  const TestPageCC(
    this.testArg, {
    Key? key,
    required this.testRequiredArg,
    this.testBoolean,
  }) : super(key: key);

  const TestPageCC.positioned(
    this.testArg, [
    this.testBoolean,
    this.testRequiredArg = '',
    Key? key,
  ]) : super(key: key);

  final int testArg;
  final String testRequiredArg;
  final bool? testBoolean;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

@FFRoute(
  name: "flutterCandies://testPage\' \"B_Copy_Copy",
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
