import 'package:example1/example1_route.dart';
import 'package:example1/example1_routes.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

import 'main.dart';

void main() {
  runApp(MyApp());
}

/// MyApp (Router=>Navigator) => NestedMainPage push
///                                             ‖
///                                             v
///                                    ChildRouterPage(Router=>Navigator) => NestedTestPage push => TestPageA
///
/// click Android hardware back button or web browser back button
///
/// if don't use ChildBackButtonDispatcher to take priority from RootBackButtonDispatcher(Parent) in
/// [ChildRouterWidget.build], it will go back to NestedMainPage directly.
///
/// child router will take back event if the ChildBackButtonDispatcher of child router
/// have took priority from RootBackButtonDispatcher(Parent).
///
/// you can override [FFRouterDelegate.popRoute] to define your logic.
///
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: FFRouteInformationParser(),
      routerDelegate: FFRouterDelegate(
        getRouteSettings: getRouteSettings,
      ),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(
          location: Routes.nestedMainPage,
        ),
      ),
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}

@FFRoute(
  name: 'NestedMainPage',
  routeName: 'NestedMainPage',
  description: 'NestedMainPage',
)
class NestedMainPage extends StatelessWidget {
  const NestedMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text('Push to ChildRouterPage'),
          onPressed: () {
            FFRouterDelegate.of(context).pushNamed(Routes.childRouterPage);
          },
        ),
      ),
    );
  }
}

@FFRoute(
  name: 'NestedTestPage',
  routeName: 'NestedTestPage',
  description: 'NestedTestPage',
)
class NestedTestPage extends StatelessWidget {
  const NestedTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text('Push to TestPageA'),
        onPressed: () {
          FFRouterDelegate.of(context).pushNamed(Routes.testPageA);
        },
      ),
    );
  }
}

@FFRoute(
  name: 'ChildRouterPage',
  routeName: 'ChildRouterPage',
  description: 'ChildRouterPage',
)
class ChildRouterPage extends StatelessWidget {
  const ChildRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChildBackButtonDispatcher childBackButtonDispatcher =
        Router.of(context)
            .backButtonDispatcher!
            .createChildBackButtonDispatcher();
    childBackButtonDispatcher.takePriority();
    return Router<RouteSettings>(
      routerDelegate: FFRouterDelegate(
        getRouteSettings: getRouteSettings,
        pageWrapper: <T>(FFPage<T> ffPage) {
          return ffPage.copyWith(
            builder: () => CommonWidget(
              routeName: ffPage.routeName,
              child: ffPage.builder(),
            ),
          );
        },
      ),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(
          location: Routes.nestedTestPage,
        ),
      ),
      backButtonDispatcher: childBackButtonDispatcher,
      routeInformationParser: FFRouteInformationParser(),
    );
  }
}
