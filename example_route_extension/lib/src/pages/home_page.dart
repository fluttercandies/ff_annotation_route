import 'package:example_route_extension/example_route_extension_routes.dart';
import 'package:example_route_extension/src/user.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://HomePage',
  routeName: 'HomePage',
  description: 'HomePage',
)
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends RouteLifecycleState<HomePage> {
  bool _hasLogin = User().hasLogin;
  @override
  void onPageShow() {
    if (_hasLogin != User().hasLogin) {
      setState(() {
        _hasLogin = User().hasLogin;
      });
    }
  }

  @override
  void onPageHide() {
    _hasLogin = User().hasLogin;
    super.onPageHide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                User().logout();
              });
            },
            icon: const Icon(
              Icons.login_outlined,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'hasLogin: ${User().hasLogin}${User().hasLogin ? ' ------ role: ${User().role}' : ''}'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedWithInterceptor(
                  Routes.fluttercandiesPageA.name,
                );
              },
              child: const Text('Go to A Page(need login)'),
            ),
            ElevatedButton(
              onPressed: () {
                NavigatorWithInterceptor.pushNamed(
                  context,
                  Routes.fluttercandiesPageB.name,
                );
              },
              child: const Text('Go to B Page(need login and amdin)'),
            ),
          ],
        ),
      ),
    );
  }
}
