import 'package:example_go_router/example_go_router_routes.dart';
import 'package:example_go_router/src/router/interceptors/interface.dart';
import 'package:example_go_router/src/user.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

class LoginInterceptor extends ILoginInterceptor {
  const LoginInterceptor();

  @override
  Future<RouteInterceptResult> intercept(
    String routeName, {
    Object? arguments,
  }) async {
    if (!User().hasLogin) {
      return RouteInterceptResult.complete(routeName: Routes.loginPage.name);
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
  Future<RouteInterceptResult> intercept(
    String routeName, {
    Object? arguments,
  }) async {
    if (routeName == Routes.pageA.name || routeName == Routes.pageB.name) {
      if (!User().hasLogin) {
        return RouteInterceptResult.complete(routeName: Routes.loginPage.name);
      }
    }

    return RouteInterceptResult.next(
      routeName: routeName,
      arguments: arguments,
    );
  }
}
