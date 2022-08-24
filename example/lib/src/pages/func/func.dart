import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'func.g.dart';

@FunctionalWidget()
@FFRoute(
  name: 'flutterCandies://func',
  routeName: 'test-func',
)
Widget func(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

@swidget
@FFRoute(
  name: 'flutterCandies://func1',
  routeName: 'test-func-1',
)
Widget func1(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

@hwidget
@FFRoute(
  name: 'flutterCandies://func2',
  routeName: 'test-func-2',
)
Widget func2(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

@hcwidget
@FFRoute(
  name: 'flutterCandies://func3',
  routeName: 'test-func-3',
)
Widget func3(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

@cwidget
@FFRoute(
  name: 'flutterCandies://func4',
  routeName: 'test-func-4',
)
Widget func4(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

@cwidget
@FFRoute(
  name: 'flutterCandies://func5',
  routeName: 'test-func-5',
)
Widget _func5(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

// Routes not support private class.
// @cwidget
// @FFRoute(
//   name: 'flutterCandies://func6',
//   routeName: 'test-func-6',
// )
// Widget __func6(
//     int a,
//     String? b, {
//       bool? c,
//       required double d,
//     }) {
//   return Container();
// }

@cwidget
@FFRoute(
  name: 'flutterCandies://func7',
  routeName: 'test-func-7',
)
Widget _$7func(
  int a,
  String? b, {
  bool? c,
  required double d,
}) {
  return Container();
}

// Routes not support private class.
// @cwidget
// @FFRoute(
//   name: 'flutterCandies://func8',
//   routeName: 'test-func-8',
// )
// Widget ___func8(
//     int a,
//     String? b, {
//       bool? c,
//       required double d,
//     }) {
//
//   return Container();
// }
