import 'package:example_route_extension/example_route_extension_routes.dart';
import 'package:example_route_extension/src/user.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

class PermissionInterceptor extends RouteInterceptor {
  const PermissionInterceptor();

  @override
  Future<RouteInterceptResult> intercept(String routeName,
      {Object? arguments}) async {
    if (!User().isAmdin) {
      showDialog(
        context: GlobalNavigator.context!,
        builder: (b) {
          return AlertDialog(
            title: const Text('Permission Denied'),
            content:
                Text('You do not have permission to access $routeName page.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(GlobalNavigator.context!).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return RouteInterceptResult.abort(
        routeName: routeName,
      );
    }

    return RouteInterceptResult.next(
      routeName: routeName,
    );
  }
}

class GlobalPermissionInterceptor extends RouteInterceptor {
  const GlobalPermissionInterceptor();
  @override
  Future<RouteInterceptResult> intercept(String routeName,
      {Object? arguments}) async {
    if (routeName == Routes.fluttercandiesPageB.name) {
      if (!User().isAmdin) {
        showDialog(
          context: GlobalNavigator.context!,
          builder: (b) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content:
                  Text('You do not have permission to access $routeName page.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(GlobalNavigator.context!).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return RouteInterceptResult.abort(
          routeName: routeName,
        );
      }
    }

    return RouteInterceptResult.next(
      routeName: routeName,
    );
  }
}
