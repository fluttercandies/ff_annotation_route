import 'package:example_go_router/example_go_router_routes.dart';
import 'package:example_go_router/src/router/go_router_route_lifecycle.dart';
import 'package:example_go_router/src/router/navigator.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

@FFRoute(name: '/index/home', routeName: 'home')
/// Home tab page with route lifecycle
class TabHomePage extends StatefulWidget {
  const TabHomePage({super.key});

  @override
  State<TabHomePage> createState() => _TabHomePageState();
}

class _TabHomePageState extends State<TabHomePage>
    with GoRouterRouteLifecycleMixin<TabHomePage> {
  int _counter = 0;
  final List<String> _lifecycleEvents = [];

  void _addEvent(String event) {
    setState(() {
      _lifecycleEvents.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} - $event',
      );
      if (_lifecycleEvents.length > 10) {
        _lifecycleEvents.removeLast();
      }
    });
  }

  @override
  void onPageShow(GoRouterState state) {
    debugPrint('📱 [TabHomePage] onPageShow - ${state.uri}');
    _addEvent('📱 onPageShow');
  }

  @override
  void onPageHide(GoRouterState state) {
    debugPrint('📴 [TabHomePage] onPageHide - ${state.uri}');
    _addEvent('📴 onPageHide');
  }

  @override
  void onForeground(GoRouterState state) {
    debugPrint('🌞 [TabHomePage] onForeground - ${state.uri}');
    _addEvent('🌞 onForeground (App resumed)');
  }

  @override
  void onBackground(GoRouterState state) {
    debugPrint('🌙 [TabHomePage] onBackground - ${state.uri}');
    _addEvent('🌙 onBackground (App paused)');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Tab'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Counter Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _incrementCounter,
                      icon: const Icon(Icons.add),
                      label: const Text('Increment'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppNavigator().push(Routes.pageA.name);
              },
              child: const Text('Go to Page A (Detail Page)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                AppNavigator().push(Routes.pageB.name);
              },
              child: const Text('Go to Page B (Detail Page)'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lifecycle Events (Last 10):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _lifecycleEvents.isEmpty
                    ? const Center(
                        child: Text(
                          'No events yet. Switch tabs or navigate to see events.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _lifecycleEvents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            title: Text(
                              _lifecycleEvents[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
