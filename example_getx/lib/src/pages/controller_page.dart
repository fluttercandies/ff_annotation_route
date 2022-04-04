import 'package:example_getx/example_getx_routes.dart';
import 'package:example_getx/src/controller/controller2.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@FFRoute(
  name: '/ControllerPage',
  routeName: 'ControllerPage',
  description: 'This is getX demo.',
  exts: <String, dynamic>{
    'group': 'demo',
    'order': 0,
  },
)
class ControllerPage extends StatelessWidget {
  ControllerPage({Key? key}) : super(key: key);
  final GetxController2 controller = Get.put(GetxController2());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ControllerPage'),
      ),
      body: Column(
        children: [
          TextButton.icon(
              onPressed: () {
                Get.toNamed(Routes.counterPage.name);
              },
              icon: const Icon(Icons.games_outlined),
              label: const Text('jump to Counter Page')),
          Expanded(
            child: Center(
              child: Obx(() {
                return Text('Total: ${controller.count.value}');
              }),
            ),
          ),
        ],
      ),
    );
  }
}
