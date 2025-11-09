// ignore_for_file: avoid_print

import 'package:example_go_router/src/router/interceptors/interface.dart';
@FFAutoImport()
import 'package:example_go_router/src/router/interceptors/login_interceptor.dart';
import 'package:example_go_router/src/router/go_router_route_lifecycle.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

@FFRoute(
  name: '/PageA',
  routeName: 'PageA',
  description: 'PageA',
  interceptors: <RouteInterceptor>[LoginInterceptor()],
  interceptorTypes: [ILoginInterceptor],
)
class PageA extends StatefulWidget {
  const PageA({super.key});

  @override
  State<PageA> createState() => _PageAState();
}

class _PageAState extends State<PageA> with GoRouterRouteLifecycleMixin<PageA> {
  final List<String> _lifecycleEvents = [];

  void _addEvent(String event) {
    setState(() {
      _lifecycleEvents.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} - $event',
      );
      if (_lifecycleEvents.length > 15) {
        _lifecycleEvents.removeLast();
      }
    });
  }

  @override
  void onPageShow(GoRouterState state) {
    debugPrint('📱 [PageA] onPageShow - ${state.uri}');
    _addEvent('📱 onPageShow');
  }

  @override
  void onPageHide(GoRouterState state) {
    debugPrint('📴 [PageA] onPageHide - ${state.uri}');
    _addEvent('📴 onPageHide');
  }

  @override
  void onForeground(GoRouterState state) {
    debugPrint('🌞 [PageA] onForeground - ${state.uri}');
    _addEvent('🌞 onForeground (App resumed)');
  }

  @override
  void onBackground(GoRouterState state) {
    debugPrint('🌙 [PageA] onBackground - ${state.uri}');
    _addEvent('🌙 onBackground (App paused)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page A (Detail)'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.article, size: 48, color: Colors.purple),
                    const SizedBox(height: 8),
                    const Text(
                      'Page A - Detail View',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This is a detail page pushed on top of the tab navigation.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (b) => const MyDialog(),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lifecycle Events (Last 15):',
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
                    ? const Center(child: Text('No events yet.'))
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

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> with RouteLifecycleMixin {
  @override
  void onRouteShow() {
    // doing something when the dialog is shown
    super.onRouteShow();
  }

  @override
  void onRouteHide() {
    // doing something when the dialog is hidden
    super.onRouteHide();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dialog'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('This is a dialog shown on top of Page A.'),
          const SizedBox(height: 8),
          const Text(
            'Note: The underlying page (Page A) remains visible, so it won\'t receive hide events.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
