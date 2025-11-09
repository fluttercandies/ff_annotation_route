import 'package:example_go_router/src/router/go_router_route_lifecycle.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

@FFRoute(name: '/index/profile', routeName: 'profile')
/// Profile tab page with route lifecycle
class TabProfilePage extends StatefulWidget {
  const TabProfilePage({super.key});

  @override
  State<TabProfilePage> createState() => _TabProfilePageState();
}

class _TabProfilePageState extends State<TabProfilePage>
    with GoRouterRouteLifecycleMixin<TabProfilePage> {
  final List<String> _lifecycleEvents = [];
  bool _isLoading = false;

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
    debugPrint('📱 [TabProfilePage] onPageShow - ${state.uri}');
    _addEvent('📱 onPageShow');
    // Simulate data refresh when page becomes visible
    _refreshData();
  }

  @override
  void onPageHide(GoRouterState state) {
    debugPrint('📴 [TabProfilePage] onPageHide - ${state.uri}');
    _addEvent('📴 onPageHide');
  }

  @override
  void onForeground(GoRouterState state) {
    debugPrint('🌞 [TabProfilePage] onForeground - ${state.uri}');
    _addEvent('🌞 onForeground (App resumed)');
  }

  @override
  void onBackground(GoRouterState state) {
    debugPrint('🌙 [TabProfilePage] onBackground - ${state.uri}');
    _addEvent('🌙 onBackground (App paused)');
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _addEvent('🔄 Data refreshed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Tab'),
        backgroundColor: Colors.green,
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      child: Text(
                        'U',
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'User Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('user@example.com'),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Profile'),
                      ),
                  ],
                ),
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
