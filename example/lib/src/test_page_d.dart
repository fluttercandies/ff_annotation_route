import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: "flutterCandies://testPage\' \"D",
  routeName: 'testPageD ' '',
  description: 'This is test \' page D.',
  exts: <String, dynamic>{
    'test': 1,
    'test1': 'string',
  },
  showStatusBar: true,
  pageRouteType: PageRouteType.material,
)
class TestPageD extends StatelessWidget {
  const TestPageD(
    this.argument, {
    this.optional = false,
    this.id = 'flutterCandies',
  });

  factory TestPageD.another0({@required String argument}) => TestPageD(
        argument,
      );
  // factory TestPageD.another1(String argument, [bool optional = false]) =>
  //     TestPageD(
  //       argument,
  //       optional: optional,
  //     );
  // factory TestPageD.another2(String argument) => TestPageD(
  //       argument,
  //     );
  // factory TestPageD.another3(String argument, {bool optional}) => TestPageD(
  //       argument,
  //       optional: optional,
  //     );
  final String argument;
  final bool optional;
  final String id;
  @override
  Widget build(BuildContext context) {
    print(argument);
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('TestPageD'),
      ),
    );
  }
}
