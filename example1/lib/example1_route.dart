// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import
import 'package:example1/src/model/test_model.dart' hide TestMode2;
import 'package:example1/src/model/test_model1.dart' hide TestMode3;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/widgets.dart';

import 'nested_router_demo.dart';
import 'src/pages/complex/test_page_d.dart';
import 'src/pages/complex/test_page_e.dart';
import 'src/pages/complex/test_page_f.dart';
import 'src/pages/main_page.dart';
import 'src/pages/simple/test_page_a.dart';
import 'src/pages/simple/test_page_b.dart';
import 'src/pages/simple/test_page_c.dart';
import 'src/pages/simple/test_page_g.dart';

FFRouteSettings getRouteSettings({
  required String name,
  Map<String, dynamic>? arguments,
  PageBuilder? notFoundPageBuilder,
}) {
  final Map<String, dynamic> safeArguments =
      arguments ?? const <String, dynamic>{};
  switch (name) {
    case '/':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => MainPage(),
        routeName: 'MainPage',
      );
    case '/demogrouppage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => DemoGroupPage(
          keyValue: asT<MapEntry<String, List<DemoRouteResult>>>(
            safeArguments['keyValue'],
          )!,
        ),
        routeName: 'DemoGroupPage',
      );
    case '/testPageA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageA(),
        routeName: 'testPageA',
        description: 'This is test page A.',
        exts: <String, dynamic>{'group': 'Simple', 'order': 0},
      );
    case '/testPageB':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageB(
          argument: asT<String?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'testPageB ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page B.",
        exts: <String, dynamic>{'group': 'Simple', 'order': 1},
      );
    case '/testPageC':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageC(),
        routeName: 'testPageC',
        description: 'Push/Pop test page.',
        exts: <String, dynamic>{'group': 'Simple', 'order': 2},
      );
    case '/testPageD':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName]?.toString() ?? '';
          switch (ctorName) {
            case 'another0':
              return TestPageD.another0(
                argument: asT<String?>(
                  safeArguments['argument'],
                ),
              );
            case 'another1':
              return TestPageD.another1(
                asT<String?>(
                  safeArguments['argument'],
                ),
                asT<bool?>(
                  safeArguments['optional'],
                  false,
                ),
              );
            case 'another2':
              return TestPageD.another2(
                asT<String?>(
                  safeArguments['argument'],
                ),
              );
            case 'another3':
              return TestPageD.another3(
                asT<String?>(
                  safeArguments['argument'],
                ),
                optional: asT<bool?>(
                  safeArguments['optional'],
                ),
              );
            case '':
            default:
              return TestPageD(
                asT<String?>(
                  safeArguments['argument'],
                ),
                optional: asT<bool?>(
                  safeArguments['optional'],
                  false,
                ),
                id: asT<String?>(
                  safeArguments['id'],
                  'flutterCandies',
                ),
              );
          }
        },
        routeName: 'testPageD ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page D.",
        exts: <String, dynamic>{'group': 'Complex', 'order': 0},
      );
    case '/testPageE':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName]?.toString() ?? '';
          switch (ctorName) {
            case 'test':
              return TestPageE.test();
            case 'requiredC':
              return TestPageE.requiredC(
                testMode: asT<TestMode?>(
                  safeArguments['testMode'],
                ),
              );
            case '':
            default:
              return TestPageE(
                testMode: asT<TestMode?>(
                  safeArguments['testMode'],
                  const TestMode(id: 2, isTest: false),
                ),
                testMode1: asT<TestMode1?>(
                  safeArguments['testMode1'],
                ),
              );
          }
        },
        routeName: 'testPageE',
        description: 'Show how to push new page with arguments(class)',
        exts: <String, dynamic>{'group': 'Complex', 'order': 1},
      );
    case '/testPageF':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageF(
          asT<List<int>?>(
            safeArguments['list'],
          ),
          map: asT<Map<String, String>?>(
            safeArguments['map'],
          ),
          testMode: asT<TestMode?>(
            safeArguments['testMode'],
          ),
        ),
        routeName: 'testPageF',
        pageRouteType: PageRouteType.material,
        description: 'This is test page F.',
        exts: <String, dynamic>{'group': 'Complex', 'order': 2},
      );
    case '/testPageG':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageG(),
        routeName: 'testPageG',
        description: 'Pop with result test page(push from TestPageC)',
        exts: <String, dynamic>{'group': 'Simple', 'order': 3},
      );
    case 'ChildRouterPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => ChildRouterPage(),
        routeName: 'ChildRouterPage',
        description: 'ChildRouterPage',
      );
    case 'NestedMainPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => NestedMainPage(),
        routeName: 'NestedMainPage',
        description: 'NestedMainPage',
      );
    case 'NestedTestPage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => NestedTestPage(),
        routeName: 'NestedTestPage',
        description: 'NestedTestPage',
      );
    default:
      return FFRouteSettings(
        name: FFRoute.notFoundName,
        routeName: FFRoute.notFoundRouteName,
        builder: notFoundPageBuilder ?? () => Container(),
      );
  }
}
