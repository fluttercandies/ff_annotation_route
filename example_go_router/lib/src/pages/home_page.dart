import 'package:example_go_router/example_go_router_routes.dart';
import 'package:example_go_router/src/router/navigator.dart';
import 'package:example_go_router/src/user.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(name: '/', routeName: 'HomePage', description: 'HomePage')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
            icon: const Icon(Icons.login_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'hasLogin: ${User().hasLogin}${User().hasLogin ? ' ------ role: ${User().role}' : ''}',
            ),
            ElevatedButton(
              onPressed: () {
                AppNavigator().push(Routes.pageA.name);
              },
              child: const Text('Go to A Page(need login)'),
            ),
            ElevatedButton(
              onPressed: () {
                AppNavigator().push(Routes.pageB.name);
              },
              child: const Text('Go to B Page(need login and amdin)'),
            ),
          ],
        ),
      ),
    );
  }
}
