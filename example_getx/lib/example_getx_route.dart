// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************
// fast mode: true
// version: 1.0.6
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import,unused_shown_name,implementation_imports,duplicate_import
import 'package:example_getx/src/bindings/bindings1.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/widgets.dart';

import 'src/pages/bindings_page.dart';
import 'src/pages/controller_page.dart';
import 'src/pages/counter_page.dart';
import 'src/pages/item_page.dart';
import 'src/pages/main_page.dart';

FFRouteSettings getRouteSettings({
  required String name,
  Map<String, dynamic>? arguments,
  PageBuilder? notFoundPageBuilder,
}) {
  final Map<String, dynamic> safeArguments =
      arguments ?? const <String, dynamic>{};
  switch (name) {
    case '/BindingsPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => BindingsPage(
          key: asT<Key?>(
            safeArguments['key'],
          ),
          argument: asT<String?>(
            safeArguments['argument'],
          ),
        ),
        codes: <String, dynamic>{
          'binding': Bindings1(),
        },
        routeName: 'BindingsPage',
        description: 'how to use Bindings with Annotation.',
        exts: <String, dynamic>{
          'group': 'demo',
          'order': 1,
        },
      );
    case '/ControllerPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => ControllerPage(
          key: asT<Key?>(
            safeArguments['key'],
          ),
        ),
        routeName: 'ControllerPage',
        description: 'This is getX demo.',
        exts: <String, dynamic>{
          'group': 'demo',
          'order': 0,
        },
      );
    case '/CounterPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => CounterPage(
          key: asT<Key?>(
            safeArguments['key'],
          ),
        ),
        description: 'This is getX counter demo.',
      );
    case '/ItemPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => ItemPage(
          index: asT<int>(
            safeArguments['index'],
          )!,
          key: asT<Key?>(
            safeArguments['key'],
          ),
        ),
      );
    case 'fluttercandies://demogrouppage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => DemoGroupPage(
          key: asT<Key?>(
            safeArguments['key'],
          ),
          keyValue: asT<MapEntry<String, List<DemoRouteResult>>>(
            safeArguments['keyValue'],
          )!,
        ),
        routeName: 'DemoGroupPage',
      );
    case 'fluttercandies://mainpage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => MainPage(
          key: asT<Key?>(
            safeArguments['key'],
          ),
        ),
        routeName: 'MainPage',
      );
    default:
      return FFRouteSettings(
        name: FFRoute.notFoundName,
        routeName: FFRoute.notFoundRouteName,
        builder: notFoundPageBuilder ?? () => Container(),
      );
  }
}
