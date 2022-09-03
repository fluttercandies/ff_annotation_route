// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import
import 'package:example/src/model/test_model.dart' hide TestMode2;
import 'package:example/src/model/test_model1.dart' hide TestMode3;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/widgets.dart';
import 'package:module_a/module_a_route.dart'
    as testpageb1afeb9c992bb2f1098d1acc6becb2a6c;
import 'package:module_a/module_a_route.dart'
    as testpagec23b284ff92265eaaa6c065105cf47f2a;
import 'package:module_a/module_a_route.dart'
    as testpaged05a916dda13cd9d2b973ee75b8e74f9d;
import 'package:module_a/module_a_route.dart'
    hide TestPageB, TestPageC, TestPageD;

import 'src/pages/complex/test_page_d.dart'
    as testpaged6c4b232f91f77ae9eb7103223363b84e;
import 'src/pages/complex/test_page_e.dart';
import 'src/pages/func/func.dart';
import 'src/pages/main_page.dart';
import 'src/pages/simple/test_page_a.dart';
import 'src/pages/simple/test_page_b.dart'
    as testpagebf579848b341a854d92dd7bfb0a9adf6c;
import 'src/pages/simple/test_page_c.dart'
    as testpagebe750dc97cdd9ac79db01471ef9768749;
import 'src/pages/simple/test_page_c.dart' hide TestPageB;
import 'src/pages/simple/test_page_c_copy.dart'
    as testpageba7e2423296cea41a98c971570832499c;
import 'src/pages/simple/test_page_c_copy.dart'
    as testpagec24a74dc0abd3133051a047c62e4d4227;
import 'src/pages/simple/test_page_c_copy_copy.dart'
    as testpagecf10ae9a1919e70b4efb736483bc2992d;

FFRouteSettings getRouteSettings({
  required String name,
  Map<String, dynamic>? arguments,
  PageBuilder? notFoundPageBuilder,
}) {
  final Map<String, dynamic> safeArguments =
      arguments ?? const <String, dynamic>{};
  switch (name) {
    case 'flutterCandies://func':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => Func(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func',
      );
    case 'flutterCandies://func1':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => Func1(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func-1',
      );
    case 'flutterCandies://func2':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => Func2(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func-2',
      );
    case 'flutterCandies://func3':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => Func3(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func-3',
      );
    case 'flutterCandies://func4':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => Func4(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func-4',
      );
    case 'flutterCandies://func5':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => Func5(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func-5',
      );
    case 'flutterCandies://func7':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => $7Func(
          asT<int>(
            safeArguments['a'],
          )!,
          asT<String?>(
            safeArguments['b'],
          ),
          key: asT<Key?>(
            safeArguments['key'],
          ),
          c: asT<bool?>(
            safeArguments['c'],
          ),
          d: asT<double>(
            safeArguments['d'],
          )!,
        ),
        routeName: 'test-func-7',
      );
    case '''flutterCandies://testPage' "B''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagebf579848b341a854d92dd7bfb0a9adf6c.TestPageB(
          argument: asT<String?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'testPageB ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page B.",
        exts: <String, dynamic>{'group': 'Simple', 'order': 1},
      );
    case '''flutterCandies://testPage' "B_Copy''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpageba7e2423296cea41a98c971570832499c.TestPageB(
          argument: asT<String?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'testPageB ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page B. has the same name",
        exts: <String, dynamic>{'group': 'Simple', 'order': 1},
      );
    case '''flutterCandies://testPage' "B_Copy_Copy''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagebe750dc97cdd9ac79db01471ef9768749.TestPageB(
          argument: asT<String?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'testPageB ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page B. has the same name",
        exts: <String, dynamic>{'group': 'Simple', 'order': 1},
      );
    case '''flutterCandies://testPage' "B_module_a''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpageb1afeb9c992bb2f1098d1acc6becb2a6c.TestPageB(
          argument: asT<String?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'testPageB ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page B. in module a",
        exts: <String, dynamic>{'group': 'Simple', 'order': 1},
      );
    case '''flutterCandies://testPage' "D''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName]?.toString() ?? '';
          switch (ctorName) {
            case 'another0':
              return testpaged6c4b232f91f77ae9eb7103223363b84e.TestPageD
                  .another0(
                argument: asT<String?>(
                  safeArguments['argument'],
                ),
              );
            case 'another1':
              return testpaged6c4b232f91f77ae9eb7103223363b84e.TestPageD
                  .another1(
                asT<String?>(
                  safeArguments['argument'],
                ),
                asT<bool?>(
                  safeArguments['optional'],
                  false,
                ),
              );
            case 'another2':
              return testpaged6c4b232f91f77ae9eb7103223363b84e.TestPageD
                  .another2(
                asT<String?>(
                  safeArguments['argument'],
                ),
              );
            case 'another3':
              return testpaged6c4b232f91f77ae9eb7103223363b84e.TestPageD
                  .another3(
                asT<String?>(
                  safeArguments['argument'],
                ),
                optional: asT<bool?>(
                  safeArguments['optional'],
                ),
              );
            case '':
            default:
              return testpaged6c4b232f91f77ae9eb7103223363b84e.TestPageD(
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
    case 'flutterCandies://testPageA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageA(),
        routeName: 'testPageA',
        description: 'This is test page A.',
        exts: <String, dynamic>{'group': 'Simple', 'order': 0},
      );
    case 'flutterCandies://testPageC':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagec23b284ff92265eaaa6c065105cf47f2a.TestPageC(),
        routeName: 'testPageC',
        description: 'This is test page c in other module.',
        exts: <String, dynamic>{'group': 'Simple', 'order': 2},
      );
    case 'flutterCandies://testPageCC':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName]?.toString() ?? '';
          switch (ctorName) {
            case 'positioned':
              return TestPageCC.positioned(
                asT<int>(
                  safeArguments['testArg'],
                )!,
                asT<bool?>(
                  safeArguments['testBoolean'],
                ),
                asT<String>(
                  safeArguments['testRequiredArg'],
                  '',
                )!,
                asT<Key?>(
                  safeArguments['key'],
                ),
              );
            case '':
            default:
              return TestPageCC(
                asT<int>(
                  safeArguments['testArg'],
                )!,
                key: asT<Key?>(
                  safeArguments['key'],
                ),
                testRequiredArg: asT<String>(
                  safeArguments['testRequiredArg'],
                )!,
                testBoolean: asT<bool?>(
                  safeArguments['testBoolean'],
                ),
              );
          }
        },
        routeName: 'testPageCC',
        description: 'This is test page CC.',
      );
    case 'flutterCandies://testPageC_Copy':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagec24a74dc0abd3133051a047c62e4d4227.TestPageC(),
        routeName: 'testPageC',
        description:
            'This is test page c has the same name with moudle_a TestPageC.',
        exts: <String, dynamic>{'group': 'Simple', 'order': 2},
      );
    case 'flutterCandies://testPageC_Copy_Copy':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagecf10ae9a1919e70b4efb736483bc2992d.TestPageC(),
        routeName: 'testPageC',
        description:
            'This is test page c has the same name with moudle_a TestPageC.',
        exts: <String, dynamic>{'group': 'Simple', 'order': 2},
      );
    case 'flutterCandies://testPageD_moduleA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpaged05a916dda13cd9d2b973ee75b8e74f9d.TestPageD(),
        routeName: 'testPageA',
        description: 'This is test page D. in module a',
        exts: <String, dynamic>{'group': 'Simple', 'order': 0},
      );
    case 'flutterCandies://testPageE':
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
    case 'flutterCandies://testPageF_moduleA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageF(),
        routeName: 'testPageA',
        description: 'This is test page F. in module a',
        exts: <String, dynamic>{'group': 'Simple', 'order': 0},
      );
    case 'fluttercandies://demogrouppage':
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
