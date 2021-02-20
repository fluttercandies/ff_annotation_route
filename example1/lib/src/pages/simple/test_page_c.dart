import 'package:example1/example1_route.dart';
import 'package:example1/example1_routes.dart';
import 'package:example1/main.dart';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

import 'test_page_a.dart';

@FFRoute(
  name: 'flutterCandies://testPageC',
  routeName: 'testPageC',
  description: 'Push/Pop test page.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 2,
  },
)
class TestPageC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            FFRouterDelegate.of(context).pushNamed<void>(
              Routes.flutterCandiesTestPageF.name,
              arguments: Routes.flutterCandiesTestPageF.d(
                <int>[1, 2, 3],
                map: <String, String>{'ddd': 'dddd'},
                testMode: const TestMode(id: 1, isTest: true),
              ),
            );
          },
          child: const Text('pushNamed'),
        ),
        FlatButton(
          onPressed: () {
            final FFRouterDelegate delegate = FFRouterDelegate.of(context);
            final FFRouteSettings routeSettings =
                getRouteSettings(name: Routes.flutterCandiesTestPageA);
            final FFPage<void> page = routeSettings.toFFPage<void>(
                // make sure it has unique key
                key: delegate.getUniqueKey(),
                widget: CommonWidget(
                  child: TestPageA(),
                  routeName: routeSettings.routeName,
                ));

            delegate.push<void>(page);
          },
          child: const Text('push'),
        ),
        FlatButton(
          onPressed: () {
            FFRouterDelegate.of(context).pushNamedAndRemoveUntil<void>(
                Routes.flutterCandiesTestPageA, (FFPage<dynamic> page) {
              return page.name == Routes.fluttercandiesMainpage;
            });
          },
          child: const Text('pushNamedAndRemoveUntil'),
        ),
        FlatButton(
          onPressed: () {
            FFRouterDelegate.of(context).pop('pop result');
          },
          child: const Text('pop'),
        ),
        FlatButton(
          onPressed: () {
            final FFRouterDelegate delegate = FFRouterDelegate.of(context);

            final FFPage<void> page = delegate.getRoutePage<void>(
                name: Routes.flutterCandiesTestPageA);

            delegate.pages.add(page);
            delegate.updatePages();
          },
          child: const Text('custom'),
        ),
        FlatButton(
          onPressed: () {
            FFRouterDelegate.of(context)
                .pushNamed<String>(
              Routes.flutterCandiesTestPageG,
            )
                .then((String value) {
              print(value);
            });
          },
          child: const Text('pushNamed and pop with result'),
        ),
      ],
    );
  }
}
