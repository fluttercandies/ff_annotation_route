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
