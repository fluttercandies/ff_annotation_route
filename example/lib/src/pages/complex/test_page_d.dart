import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: "flutterCandies://testPage' \"D",
  routeName:
      'testPageD '
      '',
  description: 'This is test \' page D.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
  showStatusBar: true,
  pageRouteType: PageRouteType.material,
)
class TestPageD extends StatelessWidget {
  const TestPageD(
    this.argument, {
    super.key,
    this.optional = false,
    this.id = 'flutterCandies',
    this.anything,
  });

  factory TestPageD.another0({required String? argument}) {
    return TestPageD(argument);
  }

  factory TestPageD.another1(String? argument, [bool? optional = false]) {
    return TestPageD(argument, optional: optional);
  }

  factory TestPageD.another2(String? argument) {
    return TestPageD(argument);
  }

  factory TestPageD.another3(
    String? argument, {
    bool? optional,
    dynamic anything,
  }) {
    return TestPageD(
      argument,
      optional: optional,
      anything: anything,
    );
  }

  final String? argument;
  final bool? optional;
  final String? id;
  final dynamic anything;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'TestPageD '
        'argument:$argument, '
        'optional:$optional, '
        'id:$id, '
        'anything:$anything',
      ),
    );
  }
}
