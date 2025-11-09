import 'package:example_go_router/example_go_router_route.dart';
import 'package:example_go_router/example_go_router_routes.dart';
import 'package:example_go_router/src/router/external_link_helper.dart';
import 'package:example_go_router/src/router/go_router_route_lifecycle.dart';
import 'package:example_go_router/src/pages/shell_container.dart';
import 'package:example_go_router/src/router/page_route.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'navigator.dart';

// Global navigator key for StatefulShellRoute

GoRouter appGoRouter = GoRouter(
  initialLocation: Routes.indexHome.name,
  navigatorKey: AppNavigator().navigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellContainer(navigationShell: navigationShell);
      },
      branches: goRouterRouteSettings
          .where((x) => x.name!.startsWith('/index/'))
          .map((settings) {
            return StatefulShellBranch(
              routes: [
                FFGoRoute(
                  settings: settings,
                  path: settings.name!,
                  caseSensitive: false,
                  pageBuilder: (context, state) {
                    return _pageBuilder(state, settings);
                  },
                ),
              ],
            );
          })
          .toList(),
    ),
    // Other routes outside the shell
    ...goRouterRouteSettings.where((r) => !r.name!.startsWith('/index/')).map((
      settings,
    ) {
      return FFGoRoute(
        settings: settings,
        path: settings.name!,
        caseSensitive: false,
        pageBuilder: (context, state) {
          return _pageBuilder(state, settings);
        },
      );
    }),
  ],
  redirect: (context, state) {
    var result = ExternalLinkHelper().parseExternalLocation(state.uri);
    if (result != null) {
      if (state.uri.queryParameters.isEmpty) {
        return result.routeName;
      }
      return '${result.routeName}?${state.uri.query}';
    }

    return null;
  },
);

// Initialize the route lifecycle service after creating the router
void initRouteLifecycleService() {
  GoRouterRouteLifecycleService.init(appGoRouter, fireOnlyLeaf: false);

  // Optional: Listen to global events for debugging
  GoRouterRouteLifecycleService.I.events.listen((event) {
    final ffgoRoute = event.state.topRoute as FFGoRoute?;
    debugPrint(
      '🔔 Global Event: ${event.type.name} - ${event.state.uri} - ${ffgoRoute?.routeName}',
    );
  });
}

Page<dynamic> _pageBuilder(
  GoRouterState state,
  FFGoRouterRouteSettings settings,
) {
  final Map<String, dynamic> safeArguments = {};
  if (state.extra != null && state.extra is Map<String, dynamic>) {
    safeArguments.addAll(state.extra as Map<String, dynamic>);
  }
  if (state.uri.queryParameters.isNotEmpty) {
    safeArguments.addAll(state.uri.queryParameters);
  }

  switch (settings.pageRouteType) {
    case PageRouteType.material:
      return MaterialPage<dynamic>(
        key: state.pageKey,
        child: settings.builder(safeArguments),
      );
    case PageRouteType.cupertino:
      return CupertinoPage<dynamic>(
        key: state.pageKey,
        child: settings.builder(safeArguments),
      );

    case PageRouteType.transparent:
      return TransparentPage<dynamic>(
        key: state.pageKey,
        child: settings.builder(safeArguments),
      );
    default:
      return CupertinoPage<dynamic>(
        key: state.pageKey,
        child: settings.builder(safeArguments),
      );
  }
}
