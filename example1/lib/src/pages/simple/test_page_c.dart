import 'package:example1/example1_route.dart';
import 'package:example1/example1_routes.dart';
import 'package:example1/main.dart';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

import 'test_page_a.dart';

@FFRoute(
  name: '/testPageC',
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
        TextButton(
          onPressed: () {
            FFRouterDelegate.of(context).pushNamed(
              Routes.testPageF.name,
              arguments: Routes.testPageF.d(
                <int>[1, 2, 3],
                map: <String, String>{'ddd': 'dddd'},
                testMode: const TestMode(id: 1, isTest: true),
              ),
            );
          },
          child: const Text('pushNamed'),
        ),
        TextButton(
          onPressed: () {
            final FFRouterDelegate delegate = FFRouterDelegate.of(context);
            final FFRouteSettings routeSettings =
                getRouteSettings(name: Routes.testPageA);
            final FFPage<void> page = routeSettings.toFFPage<void>(
                // make sure it has unique key
                key: delegate.getUniqueKey(),
                builder: () => CommonWidget(
                      child: TestPageA(),
                      routeName: routeSettings.routeName,
                    ));

            delegate.push<void>(page);
          },
          child: const Text('push'),
        ),
        TextButton(
          onPressed: () {
            FFRouterDelegate.of(context).pushNamedAndRemoveUntil(
                Routes.testPageA, (FFPage<dynamic> page) {
              return page.name == Routes.root;
            });
          },
          child: const Text('pushNamedAndRemoveUntil'),
        ),
        TextButton(
          onPressed: () {
            FFRouterDelegate.of(context).pop('pop result');
          },
          child: const Text('pop'),
        ),
        TextButton(
          onPressed: () {
            final FFRouterDelegate delegate = FFRouterDelegate.of(context);

            final FFPage<void> page =
                delegate.getRoutePage(name: Routes.testPageA);

            delegate.pages.add(page);
            delegate.updatePages();
          },
          child: const Text('custom'),
        ),
        TextButton(
          onPressed: () {
            FFRouterDelegate.of(context)
                .pushNamed<String>(
              Routes.testPageG,
            )
                .then((String? value) {
              print(value!);
            });
          },
          child: const Text('pushNamed and pop with result'),
        ),
      ],
    );
  }
}
