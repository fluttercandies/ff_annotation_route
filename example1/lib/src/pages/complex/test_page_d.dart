import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: '/testPageD',
  routeName: 'testPageD ' '',
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
  });

  factory TestPageD.another0({required String? argument}) => TestPageD(
        argument,
      );

  factory TestPageD.another1(String? argument, [bool? optional = false]) =>
      TestPageD(
        argument,
        optional: optional,
      );

  factory TestPageD.another2(String? argument) => TestPageD(
        argument,
      );

  factory TestPageD.another3(String? argument, {bool? optional}) => TestPageD(
        argument,
        optional: optional,
      );
  final String? argument;
  final bool? optional;
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('TestPageD argument:$argument,optional:$optional,id:$id'),
    );
  }
}
