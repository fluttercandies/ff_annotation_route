import 'package:example_getx/example_getx_routes.dart';
import 'package:example_getx/src/controller/controller1.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@FFRoute(
  name: "/BindingsPage",
  routeName: 'BindingsPage',
  description: 'how to use Bindings with Annotation.',
  codes: <String, String>{
    'binding': 'Bindings1()',
  },
  argumentImports: <String>[
    'import \'package:example_getx/src/bindings/bindings1.dart\';'
  ],
  exts: <String, dynamic>{
    'group': 'demo',
    'order': 1,
  },
)
class BindingsPage extends StatelessWidget {
  BindingsPage({
    Key? key,
    this.argument,
  }) : super(key: key);
  final String? argument;
  final GetxController1 controller = GetxController1.to;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BindingsPage'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemBuilder: (b, index) {
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.itemPage.name,
                    arguments: Routes.itemPage.d(index: index));
              },
              child: Card(
                child: Text('click me! $index: ${controller.list[index]}'),
              ),
            );
          },
          itemCount: controller.list.length,
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.list.add(DateTime.now().microsecondsSinceEpoch.toString());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
