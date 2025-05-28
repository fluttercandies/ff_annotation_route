// ignore_for_file: avoid_print

@FFAutoImport()
import 'package:example_route_extension/src/interceptors/login_interceptor.dart';
@FFAutoImport()
import 'package:example_route_extension/src/interceptors/permission_interceptor.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://PageB',
  routeName: 'PageB',
  description: 'PageB',
  interceptors: <RouteInterceptor>[
    LoginInterceptor(),
    PermissionInterceptor(),
  ],
)
class PageB extends StatefulWidget {
  const PageB({super.key});

  @override
  State<PageB> createState() => _PageBState();
}

class _PageBState extends RouteLifecycleState<PageB> {
  @override
  void onForeground() {
    print('PageB onForeground');
  }

  @override
  void onBackground() {
    print('PageB onBackground');
  }

  @override
  void onPageShow() {
    print('PageB onPageShow');
  }

  @override
  void onPageHide() {
    print('PageB onPageHide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page B'),
      ),
      body: GestureDetector(
        onTap: () {},
        child: const Center(
          child: Text('This is Page B'),
        ),
      ),
    );
  }
}
