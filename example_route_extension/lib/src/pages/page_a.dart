// ignore_for_file: avoid_print

@FFAutoImport()
import 'package:example_route_extension/src/interceptors/login_interceptor.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://PageA',
  routeName: 'PageA',
  description: 'PageA',
  interceptors: <RouteInterceptor>[
    LoginInterceptor(),
  ],
)
class PageA extends StatefulWidget {
  const PageA({super.key});

  @override
  State<PageA> createState() => _PageAState();
}

class _PageAState extends RouteLifecycleState<PageA> {
  @override
  void onForeground() {
    print('PageA onForeground');
  }

  @override
  void onBackground() {
    print('PageA onBackground');
  }

  @override
  void onPageShow() {
    print('PageA onPageShow');
  }

  @override
  void onPageHide() {
    print('PageA onPageHide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page A'),
      ),
      body: Builder(builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (b) {
                return const MyDialog();
              },
            );
          },
          child: const Center(
            child: Tooltip(
              message: 'Click me to show a dialog',
              child: Text('This is Page A'),
            ),
          ),
        );
      }),
    );
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends RouteLifecycleState<MyDialog> {
  @override
  void onForeground() {
    print('MyDialog onForeground');
  }

  @override
  void onBackground() {
    print('MyDialog onBackground');
  }

  @override
  void onRouteShow() {
    print('MyDialog onRouteShow');
  }

  @override
  void onRouteHide() {
    print('MyDialog onRouteHide');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          margin: const EdgeInsets.all(10),
          height: 100,
          color: Colors.red,
          alignment: Alignment.center,
          child: const Text('This is a dialog'),
        ),
        const Spacer(),
      ],
    );
  }
}
