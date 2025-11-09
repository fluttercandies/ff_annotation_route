import 'package:example_go_router/src/router/go_router_route_lifecycle.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

@FFRoute(name: '/index/settings', routeName: 'settings')
/// Settings tab page with route lifecycle
class TabSettingsPage extends StatefulWidget {
  const TabSettingsPage({super.key});

  @override
  State<TabSettingsPage> createState() => _TabSettingsPageState();
}

class _TabSettingsPageState extends State<TabSettingsPage>
    with GoRouterRouteLifecycleMixin<TabSettingsPage> {
  final List<String> _lifecycleEvents = [];
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

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
    debugPrint('📱 [TabSettingsPage] onPageShow - ${state.uri}');
    _addEvent('📱 onPageShow');
  }

  @override
  void onPageHide(GoRouterState state) {
    debugPrint('📴 [TabSettingsPage] onPageHide - ${state.uri}');
    _addEvent('📴 onPageHide');
  }

  @override
  void onForeground(GoRouterState state) {
    debugPrint('🌞 [TabSettingsPage] onForeground - ${state.uri}');
    _addEvent('🌞 onForeground (App resumed)');
  }

  @override
  void onBackground(GoRouterState state) {
    debugPrint('🌙 [TabSettingsPage] onBackground - ${state.uri}');
    _addEvent('🌙 onBackground (App paused)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Tab'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _addEvent(
                        '⚙️ Notifications ${value ? "enabled" : "disabled"}',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                      _addEvent(
                        '⚙️ Dark mode ${value ? "enabled" : "disabled"}',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                    trailing: const Icon(Icons.info_outline),
                  ),
                ],
              ),
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
