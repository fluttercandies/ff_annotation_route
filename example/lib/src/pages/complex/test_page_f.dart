import 'dart:io';
import 'dart:ui' as ui;
import 'package:example/example_routes.dart';
import 'package:example/src/model/test_model1.dart';
import 'package:example/src/model/test_model2.dart' as model2;
import 'package:example/src/typedef.dart';
import 'package:example/src/typedef.dart' as type;
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'flutterCandies://TestPageF',
  routeName: 'TestPageF',
  description: 'Show how to push new page with arguments(class)',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 2,
  },
)
class TestPageF extends StatelessWidget {
  const TestPageF({
    this.boxWidthStyle = ui.BoxWidthStyle.max,
    this.extendedImageMode = ExtendedImageMode.gesture,
    required this.details,
    required ui.BlendMode blendMode,
    required this.file,
    required this.modes,
    required this.function,
    required this.function1,
    required this.function2,
    required this.function3,
    required this.aFunction,
    required this.myInt,
    required this.function4,
    this.typedefClass1 = const type.TypedefClass1(1),
    // not support
    //this.typedefClass = const type.TypedefClass(ui.BoxWidthStyle.max),
    // not support
    //this.myTypedefClass = myTypedefClassConst,
  }) : _blendMode = blendMode;

  final ui.BlendMode _blendMode;

  final ui.BoxWidthStyle boxWidthStyle;
  final ExtendedImageMode extendedImageMode;
  final DragDownDetails details;
  final File file;
  final List<TestMode3> modes;
  final Widget Function(String value) function;
  final TestMode3 Function(DragDownDetails value) function1;
  final model2.TestMode3 Function(Map<TestMode1, TestMode2> value) function2;
  final bool Function(String s) Function(
      int i, TestMode2 Function(DragDownDetails value) input) function3;
  final AFunction aFunction;
  final MyInt myInt;
  final AFunction Function(int Function(String s) s) Function(
      int i, MyInt Function(int value) input) function4;
  final type.TypedefClass1 typedefClass1;
  // not support
  //final type.TypedefClass typedefClass;
  // not support
  //final MyTypedefClass myTypedefClass;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Text('TestPageE $boxWidthStyle $_blendMode $file'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.flutterCandiesTestPageE.name,
                arguments: Routes.flutterCandiesTestPageE.test());
          },
          child: const Text(
            'TestPageF.deafult()',
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'TestPageF.required()',
          ),
        ),
      ],
    );
  }
}
