// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************
// fast mode: true
// version: 10.0.10
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import,unused_shown_name,implementation_imports,duplicate_import,library_private_types_in_public_api
import 'package:example_route_extension/src/interceptors/login_interceptor.dart';
import 'package:example_route_extension/src/interceptors/permission_interceptor.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';

/// The routeNames auto generated by https://github.com/fluttercandies/ff_annotation_route
const List<String> routeNames = <String>[
  'fluttercandies://HomePage',
  'fluttercandies://LoginPage',
  'fluttercandies://PageA',
  'fluttercandies://PageB',
];

/// The routeInterceptors auto generated by https://github.com/fluttercandies/ff_annotation_route
const Map<String, List<RouteInterceptor>> routeInterceptors =
    <String, List<RouteInterceptor>>{
  'fluttercandies://PageA': <RouteInterceptor>[LoginInterceptor()],
  'fluttercandies://PageB': <RouteInterceptor>[
    LoginInterceptor(),
    PermissionInterceptor()
  ],
};

/// The routes auto generated by https://github.com/fluttercandies/ff_annotation_route
class Routes {
  const Routes._();

  /// 'HomePage'
  ///
  /// [name] : 'fluttercandies://HomePage'
  ///
  /// [routeName] : 'HomePage'
  ///
  /// [description] : 'HomePage'
  ///
  /// [constructors] :
  ///
  /// HomePage : [Key? key]
  static const _FluttercandiesHomePage fluttercandiesHomePage =
      _FluttercandiesHomePage();

  /// 'LoginPage'
  ///
  /// [name] : 'fluttercandies://LoginPage'
  ///
  /// [routeName] : 'LoginPage'
  ///
  /// [description] : 'LoginPage'
  ///
  /// [constructors] :
  ///
  /// LoginPage : [Key? key]
  static const _FluttercandiesLoginPage fluttercandiesLoginPage =
      _FluttercandiesLoginPage();

  /// 'PageA'
  ///
  /// [name] : 'fluttercandies://PageA'
  ///
  /// [routeName] : 'PageA'
  ///
  /// [description] : 'PageA'
  ///
  /// [constructors] :
  ///
  /// PageA : [Key? key]
  static const _FluttercandiesPageA fluttercandiesPageA =
      _FluttercandiesPageA();

  /// 'PageB'
  ///
  /// [name] : 'fluttercandies://PageB'
  ///
  /// [routeName] : 'PageB'
  ///
  /// [description] : 'PageB'
  ///
  /// [constructors] :
  ///
  /// PageB : [Key? key]
  static const _FluttercandiesPageB fluttercandiesPageB =
      _FluttercandiesPageB();
}

class _FluttercandiesHomePage {
  const _FluttercandiesHomePage();

  String get name => 'fluttercandies://HomePage';

  Map<String, dynamic> d({
    Key? key,
  }) =>
      <String, dynamic>{
        'key': key,
      };

  @override
  String toString() => name;
}

class _FluttercandiesLoginPage {
  const _FluttercandiesLoginPage();

  String get name => 'fluttercandies://LoginPage';

  Map<String, dynamic> d({
    Key? key,
  }) =>
      <String, dynamic>{
        'key': key,
      };

  @override
  String toString() => name;
}

class _FluttercandiesPageA {
  const _FluttercandiesPageA();

  String get name => 'fluttercandies://PageA';

  Map<String, dynamic> d({
    Key? key,
  }) =>
      <String, dynamic>{
        'key': key,
      };

  @override
  String toString() => name;
}

class _FluttercandiesPageB {
  const _FluttercandiesPageB();

  String get name => 'fluttercandies://PageB';

  Map<String, dynamic> d({
    Key? key,
  }) =>
      <String, dynamic>{
        'key': key,
      };

  @override
  String toString() => name;
}
