import 'package:flutter/material.dart';

void main() => runApp(NavigatorDemo());

class NavigatorDemo extends StatefulWidget {
  const NavigatorDemo({super.key});

  @override
  State<NavigatorDemo> createState() => _NavigatorDemoState();
}

class _NavigatorDemoState extends State<NavigatorDemo> {
  final List<MyPage> _pages = <MyPage>[
    MyPage(
        name: 'MainPage', widget: const TestPage('MainPage'), key: UniqueKey()),
  ];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 60,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _pages.add(
                      MyPage(
                          name: 'MainPageA',
                          widget: const TestPage('MainPageA'),
                          key: UniqueKey()),
                    );
                    updatePages();
                  },
                  child: const Text('Push PageA'),
                ),
                TextButton(
                  onPressed: () {
                    if (_pages.length > 1) {
                      _pages.removeLast();
                      updatePages();
                    }
                  },
                  child: const Text('Pop'),
                ),
                TextButton(
                  onPressed: () {
                    // This will invoke onPopPage call back
                    navigatorKey.currentState!.pop();
                  },
                  child: const Text('Pop'),
                ),
              ],
            ),
            Expanded(
              child: Navigator(
                reportsRouteUpdateToEngine: true,
                key: navigatorKey,
                // make sure the pages are new ones.
                pages: _pages.toList(),
                // navigatorKey.currentState.pop() and Appbar back button will call this call back.
                onPopPage: (Route<dynamic> route, dynamic result) {
                  if (_pages.length > 1) {
                    _pages.removeLast();
                    updatePages();
                    return route.didPop(result);
                  }
                  return false;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updatePages() {
    _debugCheckDuplicatedPageKeys();
    setState(() {});
  }

  void _debugCheckDuplicatedPageKeys() {
    assert(() {
      final Set<Key?> keyReservation = <Key?>{};
      for (final Page<dynamic> page in _pages) {
        if (page.key != null) {
          assert(!keyReservation.contains(page.key));
          keyReservation.add(page.key);
        }
      }
      return true;
    }());
  }
}

class TestPage extends StatelessWidget {
  const TestPage(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(title),
      ),
    );
  }
}

class MyPage extends Page<void> {
  const MyPage({
    required LocalKey super.key,
    required String super.name,
    required this.widget,
    super.arguments,
  });

  final Widget widget;

  @override
  Route<void> createRoute(BuildContext context) {
    return MaterialPageRoute<void>(
      settings: this,
      builder: (BuildContext context) => widget,
    );
  }
}
