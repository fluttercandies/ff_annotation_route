import 'package:example_route_extension/example_route_extension_routes.dart';
import 'package:example_route_extension/src/user.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

class LoginInterceptor extends RouteInterceptor {
  const LoginInterceptor();

  @override
  Future<RouteInterceptResult> intercept(
    String routeName, {
    Object? arguments,
  }) async {
    if (!User().hasLogin) {
      return RouteInterceptResult.complete(
        routeName: Routes.fluttercandiesLoginPage.name,
      );
    }

    return RouteInterceptResult.next(
      routeName: routeName,
      arguments: arguments,
    );
  }
}

class GlobalLoginInterceptor extends RouteInterceptor {
  const GlobalLoginInterceptor();
  @override
  Future<RouteInterceptResult> intercept(String routeName,
      {Object? arguments}) async {
    if (routeName == Routes.fluttercandiesPageB.name ||
        routeName == Routes.fluttercandiesPageA.name) {
      if (!User().hasLogin) {
        return RouteInterceptResult.complete(
          routeName: Routes.fluttercandiesLoginPage.name,
        );
      }
    }

    return RouteInterceptResult.next(
      routeName: routeName,
      arguments: arguments,
    );
  }
}
