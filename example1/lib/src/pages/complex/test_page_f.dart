import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: '/testPageF',
  routeName: 'testPageF',
  description: 'This is test page F.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 2,
  },
  showStatusBar: true,
  pageRouteType: PageRouteType.material,
)
class TestPageF extends StatelessWidget {
  const TestPageF(
    this.list, {
    Key? key,
    this.map,
    this.testMode,
  }) : super(key: key);

  final List<int>? list;
  final Map<String, String>? map;
  final TestMode? testMode;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('TestPageF list:$list,map:$map,testMode:$testMode'));
  }
}
