import 'package:collection/collection.dart';
import 'package:example1/example1_route.dart';
import 'package:example1/example1_routes.dart' as example_routes;
import 'package:example1/example1_routes.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

@FFRoute(
  name: '/',
  routeName: 'MainPage',
)
class MainPage extends StatelessWidget {
  MainPage() {
    final List<String> routeNames = <String>[];
    routeNames.addAll(example_routes.routeNames);
    routeNames.remove(Routes.root);
    routeNames.remove(Routes.demogrouppage.name);
    routesGroup.addAll(groupBy<DemoRouteResult, String>(
        routeNames
            .map<FFRouteSettings>((String name) => getRouteSettings(name: name))
            .where((FFRouteSettings element) => element.exts != null)
            .map<DemoRouteResult>((FFRouteSettings e) => DemoRouteResult(e))
            .toList()
          ..sort((DemoRouteResult a, DemoRouteResult b) =>
              b.group.compareTo(a.group)),
        (DemoRouteResult x) => x.group));
  }
  final Map<String, List<DemoRouteResult>> routesGroup =
      <String, List<DemoRouteResult>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('ff_annotation_route'),
        actions: <Widget>[
          ButtonTheme(
            minWidth: 0.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextButton(
              child: const Text(
                'Github',
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                launchUrlString(
                    'https://github.com/fluttercandies/ff_annotation_route');
              },
            ),
          ),
          if (!kIsWeb)
            ButtonTheme(
              padding: const EdgeInsets.only(right: 10.0),
              minWidth: 0.0,
              child: TextButton(
                child: Image.network(
                    'https://pub.idqqimg.com/wpa/images/group.png'),
                onPressed: () {
                  launchUrlString('https://jq.qq.com/?_wv=1027&k=5bcc0gy');
                },
              ),
            )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          // final RouteResult page = routes[index];
          final String type = routesGroup.keys.toList()[index];
          return Container(
              margin: const EdgeInsets.all(20.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (index + 1).toString() + '.' + type,
                      //style: TextStyle(inherit: false),
                    ),
                    Text(
                      '$type demos of ff_annotation_route',
                      //page.description,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                onTap: () {
                  FFRouterDelegate.of(context).pushNamed(
                      Routes.demogrouppage.name,
                      arguments: Routes.demogrouppage
                          .d(keyValue: routesGroup.entries.toList()[index]));
                },
              ));
        },
        itemCount: routesGroup.length,
      ),
    );
  }
}

@FFRoute(
  name: '/demogrouppage',
  routeName: 'DemoGroupPage',
  argumentImports: <String>['import \'src/pages/main_page.dart\';'],
)
class DemoGroupPage extends StatelessWidget {
  DemoGroupPage({required MapEntry<String, List<DemoRouteResult>> keyValue})
      : routes = keyValue.value
          ..sort((DemoRouteResult a, DemoRouteResult b) =>
              a.order.compareTo(b.order)),
        group = keyValue.key;
  final List<DemoRouteResult> routes;
  final String group;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$group demos'),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final DemoRouteResult page = routes[index];
          return Container(
            margin: const EdgeInsets.all(20.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (index + 1).toString() + '.' + page.routeResult.routeName!,
                    //style: TextStyle(inherit: false),
                  ),
                  Text(
                    page.routeResult.description!,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
              onTap: () {
                FFRouterDelegate.of(context).pushNamed(page.routeResult.name!,
                    arguments: <String, dynamic>{
                      'argument': 'I\m argument',
                      'optional': true,
                      'id': 'test id',
                    });
              },
            ),
          );
        },
        itemCount: routes.length,
      ),
    );
  }
}

class DemoRouteResult {
  DemoRouteResult(
    this.routeResult,
  )   : order = routeResult.exts!['order'] as int,
        group = routeResult.exts!['group'] as String;

  final int order;
  final String group;
  final FFRouteSettings routeResult;

  Map<String, dynamic> get toJson => <String, dynamic>{
        'order': order,
        'group': group,
        'routeResult': routeResult,
      };
}
