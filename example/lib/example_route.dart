// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import,unused_shown_name,implementation_imports
import 'dart:io' as autoimportd66e09f4babbdbbe015b32cc3816761d;
import 'dart:ui' as autoimportde7367a4dccc7f836046967508c09a6c;

import 'package:example/src/model/test_model.dart'
    as autoimport7b0d8961824b1df42839aaf6ee621592;
import 'package:example/src/model/test_model1.dart'
    as autoimportfd790b2c4cbc8e7d99977cab283b94ab;
import 'package:example/src/model/test_model2.dart'
    as autoimport14790b17a5a1427ada8188fbf75b352c;
import 'package:example/src/pages/main_page.dart'
    as autoimport19a8136766d530a60dc5d464509fd9eb;
import 'package:extended_image/src/utils.dart'
    as autoimporte9848a6dfb6bcdd3203dea5d89c0972f;
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/src/foundation/key.dart'
    as autoimport61a64860a48a0a727515bc4ec00b2fff;
import 'package:flutter/src/gestures/drag_details.dart'
    as autoimport1e2f7b96e6c9c283a2a35bf82237bf16;
import 'package:flutter/src/widgets/framework.dart'
    as autoimport2ac85d6b777135304f548b8ca2707514;
import 'package:flutter/widgets.dart';
import 'package:module_a/module_a_route.dart'
    as testpageb1afeb9c992bb2f1098d1acc6becb2a6c;
import 'package:module_a/module_a_route.dart'
    as testpagec23b284ff92265eaaa6c065105cf47f2a;
import 'package:module_a/module_a_route.dart'
    as testpaged05a916dda13cd9d2b973ee75b8e74f9d;
import 'package:module_a/module_a_route.dart'
    as testpagef659cb97d54edf7d4349710e906c4d437;
import 'package:module_a/src/mode/mode.dart'
    as autoimportac41f6e44f4086b72b4f7dbc1ab40cc1;

import 'src/pages/complex/test_page_d.dart'
    as testpaged6c4b232f91f77ae9eb7103223363b84e;
import 'src/pages/complex/test_page_e.dart';
import 'src/pages/complex/test_page_f.dart'
    as testpagef9823c51efb96c2d241b9668f95da35ed;
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
import 'src/pages/super_parameters/test_page_super_parameters.dart';

FFRouteSettings getRouteSettings({
  required String name,
  Map<String, dynamic>? arguments,
  PageBuilder? notFoundPageBuilder,
}) {
  Map<String, dynamic> safeArguments = arguments ?? const <String, dynamic>{};
  if (arguments != null && arguments.isNotEmpty) {
    final Map<String, dynamic> ignoreCaseMap = <String, dynamic>{};
    safeArguments.forEach((String key, dynamic value) {
      ignoreCaseMap[key.toLowerCase()] = value;
    });
    safeArguments = ignoreCaseMap;
  }
  switch (name) {
    case 'flutterCandies://TestPageF':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagef9823c51efb96c2d241b9668f95da35ed.TestPageF(
          boxWidthStyle:
              asT<autoimportde7367a4dccc7f836046967508c09a6c.BoxWidthStyle>(
            safeArguments['boxwidthstyle'],
            autoimportde7367a4dccc7f836046967508c09a6c.BoxWidthStyle.max,
          )!,
          extendedImageMode:
              asT<autoimporte9848a6dfb6bcdd3203dea5d89c0972f.ExtendedImageMode>(
            safeArguments['extendedimagemode'],
            autoimporte9848a6dfb6bcdd3203dea5d89c0972f
                .ExtendedImageMode.gesture,
          )!,
          details:
              asT<autoimport1e2f7b96e6c9c283a2a35bf82237bf16.DragDownDetails>(
            safeArguments['details'],
          )!,
          blendMode: asT<autoimportde7367a4dccc7f836046967508c09a6c.BlendMode>(
            safeArguments['blendmode'],
          )!,
          file: asT<autoimportd66e09f4babbdbbe015b32cc3816761d.File>(
            safeArguments['file'],
          )!,
          modes:
              asT<List<autoimportfd790b2c4cbc8e7d99977cab283b94ab.TestMode3>>(
            safeArguments['modes'],
          )!,
          function: asT<
              autoimport2ac85d6b777135304f548b8ca2707514.Widget Function(
                  String)>(
            safeArguments['function'],
          )!,
          function1: asT<
              autoimportfd790b2c4cbc8e7d99977cab283b94ab.TestMode3 Function(
                  autoimport1e2f7b96e6c9c283a2a35bf82237bf16.DragDownDetails)>(
            safeArguments['function1'],
          )!,
          function2: asT<
              autoimport14790b17a5a1427ada8188fbf75b352c.TestMode3 Function(
                  Map<autoimportfd790b2c4cbc8e7d99977cab283b94ab.TestMode1,
                      autoimportfd790b2c4cbc8e7d99977cab283b94ab.TestMode2>)>(
            safeArguments['function2'],
          )!,
          function3: asT<
              bool Function(String) Function(
                  int,
                  autoimportfd790b2c4cbc8e7d99977cab283b94ab.TestMode2 Function(
                      autoimport1e2f7b96e6c9c283a2a35bf82237bf16
                          .DragDownDetails))>(
            safeArguments['function3'],
          )!,
        ),
        routeName: 'TestPageF',
        description: 'Show how to push new page with arguments(class)',
        exts: <String, dynamic>{
          'group': 'Complex',
          'order': 2,
        },
      );
    case 'flutterCandies://TestPageSuperParameters':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageSuperParameters(
          argument: asT<autoimportac41f6e44f4086b72b4f7dbc1ab40cc1.TestMode?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'TestPageSuperParameters ',
        pageRouteType: PageRouteType.material,
        description: 'This is super parameter test page.',
        exts: <String, dynamic>{
          'group': 'Complex',
          'order': 2,
        },
      );
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 1,
        },
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
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 1,
        },
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
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 1,
        },
      );
    case '''flutterCandies://testPage' "B_module_a''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpageb1afeb9c992bb2f1098d1acc6becb2a6c.TestPageB(
          argument: asT<autoimportac41f6e44f4086b72b4f7dbc1ab40cc1.TestMode?>(
            safeArguments['argument'],
          ),
        ),
        routeName: 'testPageB ',
        pageRouteType: PageRouteType.material,
        description: "This is test ' page B. in module a",
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 1,
        },
      );
    case '''flutterCandies://testPage' "D''':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName.toLowerCase()]?.toString() ?? '';
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
        exts: <String, dynamic>{
          'group': 'Complex',
          'order': 0,
        },
      );
    case 'flutterCandies://testPageA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => TestPageA(),
        codes: <String, dynamic>{
          'test2': TestPageA.dd,
          'test3': TestPageA.ddd,
          'test4': TestPageA(),
          'test5': TestPageA.ddd,
        },
        routeName: 'testPageA',
        description: 'This is test page A.',
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 0,
          'test6': TestPageA.dd,
        },
      );
    case 'flutterCandies://testPageC':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagec23b284ff92265eaaa6c065105cf47f2a.TestPageC(),
        routeName: 'testPageC',
        description: 'This is test page c in other module.',
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 2,
        },
      );
    case 'flutterCandies://testPageCC':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName.toLowerCase()]?.toString() ?? '';
          switch (ctorName) {
            case 'positioned':
              return TestPageCC.positioned(
                asT<int>(
                  safeArguments['testarg'],
                )!,
                asT<bool?>(
                  safeArguments['testboolean'],
                ),
                asT<String>(
                  safeArguments['testrequiredarg'],
                  '',
                )!,
                asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
                  safeArguments['key'],
                ),
              );
            case '':
            default:
              return TestPageCC(
                asT<int>(
                  safeArguments['testarg'],
                )!,
                key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
                  safeArguments['key'],
                ),
                testRequiredArg: asT<String>(
                  safeArguments['testrequiredarg'],
                )!,
                testBoolean: asT<bool?>(
                  safeArguments['testboolean'],
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
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 2,
        },
      );
    case 'flutterCandies://testPageC_Copy_Copy':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagecf10ae9a1919e70b4efb736483bc2992d.TestPageC(),
        routeName: 'testPageC',
        description:
            'This is test page c has the same name with moudle_a TestPageC.',
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 2,
        },
      );
    case 'flutterCandies://testPageD_moduleA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpaged05a916dda13cd9d2b973ee75b8e74f9d.TestPageD(),
        routeName: 'testPageA',
        description: 'This is test page D. in module a',
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 0,
        },
      );
    case 'flutterCandies://testPageE':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () {
          final String ctorName =
              safeArguments[constructorName.toLowerCase()]?.toString() ?? '';
          switch (ctorName) {
            case 'test':
              return TestPageE.test();
            case 'requiredC':
              return TestPageE.requiredC(
                testMode:
                    asT<autoimport7b0d8961824b1df42839aaf6ee621592.TestMode?>(
                  safeArguments['testmode'],
                ),
              );
            case '':
            default:
              return TestPageE(
                testMode:
                    asT<autoimport7b0d8961824b1df42839aaf6ee621592.TestMode?>(
                  safeArguments['testmode'],
                  const autoimport7b0d8961824b1df42839aaf6ee621592.TestMode(
                      id: 2, isTest: false),
                ),
                testMode1:
                    asT<autoimportfd790b2c4cbc8e7d99977cab283b94ab.TestMode1?>(
                  safeArguments['testmode1'],
                ),
              );
          }
        },
        routeName: 'testPageE',
        description: 'Show how to push new page with arguments(class)',
        exts: <String, dynamic>{
          'group': 'Complex',
          'order': 1,
        },
      );
    case 'flutterCandies://testPageF_moduleA':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => testpagef659cb97d54edf7d4349710e906c4d437.TestPageF(),
        routeName: 'testPageA',
        description: 'This is test page F. in module a',
        exts: <String, dynamic>{
          'group': 'Simple',
          'order': 0,
        },
      );
    case 'fluttercandies://demogrouppage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => DemoGroupPage(
          keyValue: asT<
              MapEntry<
                  String,
                  List<
                      autoimport19a8136766d530a60dc5d464509fd9eb
                          .DemoRouteResult>>>(
            safeArguments['keyvalue'],
          )!,
        ),
        routeName: 'DemoGroupPage',
      );
    case 'fluttercandies://mainpage':
      return FFRouteSettings(
        name: name,
        arguments: arguments,
        builder: () => MainPage(
          key: asT<autoimport61a64860a48a0a727515bc4ec00b2fff.Key?>(
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
