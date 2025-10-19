// ignore_for_file: use_build_context_synchronously

import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Singleton Navigator for the app, providing a global navigator key and navigation methods.
class AppNavigator {
  factory AppNavigator() => _navigator;
  AppNavigator._();
  static final AppNavigator _navigator = AppNavigator._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalNavigator.navigatorKey;

  /// Current BuildContext from the navigator key.
  BuildContext get context => navigatorKey.currentContext!;

  /// Get a location from route name and parameters.
  ///
  /// This method can't be called during redirects.
  // String namedLocation(
  //   String name, {
  //   Map<String, String> pathParameters = const <String, String>{},
  //   Map<String, dynamic> queryParameters = const <String, dynamic>{},
  //   String? fragment,
  // }) => context.namedLocation(
  //   name,
  //   pathParameters: pathParameters,
  //   queryParameters: queryParameters,
  //   fragment: fragment,
  // );

  /// Navigate to a location.
  Future<void> go(String location, {Object? extra}) async {
    final RouteInterceptResult? result = await intercept(
      location,
      arguments: extra,
    );
    if (result == null) {
      return;
    }
    context.go(result.routeName, extra: result.arguments);
  }

  /// Navigate to a named route.
  // void goNamed(
  //   String name, {
  //   Map<String, String> pathParameters = const <String, String>{},
  //   Map<String, dynamic> queryParameters = const <String, dynamic>{},
  //   Object? extra,
  //   String? fragment,
  // }) => context.goNamed(
  //   name,
  //   pathParameters: pathParameters,
  //   queryParameters: queryParameters,
  //   extra: extra,
  //   fragment: fragment,
  // );

  /// Push a location onto the page stack.
  ///
  /// See also:
  /// * [pushReplacement] which replaces the top-most page of the page stack and
  ///   always uses a new page key.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    final RouteInterceptResult? result = await intercept(
      location,
      arguments: extra,
    );
    if (result == null) {
      return null;
    }
    return context.push<T>(result.routeName, extra: result.arguments);
  }

  /// Navigate to a named route onto the page stack.
  // Future<T?> pushNamed<T extends Object?>(
  //   String name, {
  //   Map<String, String> pathParameters = const <String, String>{},
  //   Map<String, dynamic> queryParameters = const <String, dynamic>{},
  //   Object? extra,
  // }) => context.pushNamed<T>(
  //   name,
  //   pathParameters: pathParameters,
  //   queryParameters: queryParameters,
  //   extra: extra,
  // );

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() => context.canPop();

  /// Pop the top page off the Navigator's page stack by calling
  /// [Navigator.pop].
  void pop<T extends Object?>([T? result]) => context.pop(result);

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the given location onto the page stack.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<void> pushReplacement(String location, {Object? extra}) async {
    final RouteInterceptResult? result = await intercept(
      location,
      arguments: extra,
    );
    if (result == null) {
      return;
    }
    context.pushReplacement(result.routeName, extra: result.arguments);
  }

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', pathParameters={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  // void pushReplacementNamed(
  //   String name, {
  //   Map<String, String> pathParameters = const <String, String>{},
  //   Map<String, dynamic> queryParameters = const <String, dynamic>{},
  //   Object? extra,
  // }) => context.pushReplacementNamed(
  //   name,
  //   pathParameters: pathParameters,
  //   queryParameters: queryParameters,
  //   extra: extra,
  // );

  /// Replaces the top-most page of the page stack with the given one but treats
  /// it as the same page.
  ///
  /// The page key will be reused. This will preserve the state and not run any
  /// page animation.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  /// * [pushReplacement] which replaces the top-most page of the page stack but
  ///   always uses a new page key.
  Future<void> replace(String location, {Object? extra}) async {
    final RouteInterceptResult? result = await intercept(
      location,
      arguments: extra,
    );
    if (result == null) {
      return;
    }
    context.replace(result.routeName, extra: result.arguments);
  }

  /// Replaces the top-most page with the named route and optional parameters,
  /// preserving the page key.
  ///
  /// This will preserve the state and not run any page animation. Optional
  /// parameters can be provided to the named route, e.g. `name='person',
  /// pathParameters={'fid': 'f2', 'pid': 'p1'}`.
  ///
  /// See also:
  /// * [pushNamed] which pushes the given location onto the page stack.
  /// * [pushReplacementNamed] which replaces the top-most page of the page
  ///   stack but always uses a new page key.
  // void replaceNamed(
  //   String name, {
  //   Map<String, String> pathParameters = const <String, String>{},
  //   Map<String, dynamic> queryParameters = const <String, dynamic>{},
  //   Object? extra,
  // }) => context.replaceNamed(
  //   name,
  //   pathParameters: pathParameters,
  //   queryParameters: queryParameters,
  //   extra: extra,
  // );

  /// Intercept a route before navigation.
  Future<RouteInterceptResult?> intercept(
    String routeName, {
    Object? arguments,
  }) async {
    final RouteInterceptResult result = await RouteInterceptorManager()
        .intercept(routeName, arguments: arguments);
    if (result.action == RouteInterceptAction.abort) {
      return null;
    }

    return result;
  }
}
