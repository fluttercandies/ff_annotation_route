// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************

import 'package:flutter/widgets.dart';

import 'package:flutter_candies_demo_library/flutter_candies_demo_library_route.dart';
import 'package:module_a/module_a_route.dart';
import 'src/main_page.dart';
import 'src/test_page_a.dart';
import 'src/test_page_b.dart';

// ignore_for_file: argument_type_not_assignable
RouteResult getRouteResult({String name, Map<String, dynamic> arguments}) {
  switch (name) {
    case 'flutterCandies://mainPage':
      return RouteResult(
        name: name,
        widget: MainPage(),
        routeName: 'MainPage',
      );
    case 'flutterCandies://testPageA':
      return RouteResult(
        name: name,
        widget: TestPageA(),
        routeName: 'testPageA',
        description: 'This is test page A.',
      );
    case 'flutterCandies://testPageB':
      return RouteResult(
        name: name,
        widget: TestPageB(
          argument: arguments['argument'],
        ),
        routeName: 'testPageB',
        description: 'This is test page B.',
        exts: <String, dynamic>{'test': 1, 'test1': 'string'},
      );
    case 'flutterCandies://testPageC':
      return RouteResult(
        name: name,
        widget: TestPageC(),
        routeName: 'testPageC',
        description: 'This is test page c in other module.',
      );
    case 'fluttercandies://picswiper':
      return RouteResult(
        name: name,
        widget: PicSwiper(
          index: arguments['index'],
          pics: arguments['pics'],
          tuChongItem: arguments['tuChongItem'],
        ),
        showStatusBar: false,
        routeName: 'PicSwiper',
        pageRouteType: PageRouteType.transparent,
      );
    default:
      return const RouteResult(name: 'flutterCandies://notfound');
  }
}

class RouteResult {
  const RouteResult({
    @required this.name,
    this.widget,
    this.showStatusBar = true,
    this.routeName = '',
    this.pageRouteType,
    this.description = '',
    this.exts,
  });

  /// The name of the route (e.g., "/settings").
  ///
  /// If null, the route is anonymous.
  final String name;

  /// The Widget return base on route
  final Widget widget;

  /// Whether show this route with status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  /// The extend arguments
  final Map<String, dynamic> exts;
}

enum PageRouteType {
  material,
  cupertino,
  transparent,
}
