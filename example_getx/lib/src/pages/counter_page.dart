import 'package:example_getx/src/controller/controller2.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@FFRoute(
  name: '/CounterPage',
  description: 'This is getX counter demo.',
)
class CounterPage extends StatelessWidget {
  CounterPage({super.key});

  final GetxController2 controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CounterPage'),
      ),
      body: Center(
        child: Obx(() {
          return Text('Total: ${controller.count.value}');
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.count++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
