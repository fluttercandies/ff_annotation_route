import 'package:flutter/material.dart';
@FFArgumentImport()
import 'package:flutter/foundation.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

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
