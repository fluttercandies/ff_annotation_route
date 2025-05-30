import 'package:example_getx/src/controller/controller1.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@FFRoute(name: '/ItemPage')
class ItemPage extends StatelessWidget {
  ItemPage({required this.index, super.key});
  final GetxController1 controller = GetxController1.to;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ItemPage'),
      ),
      body: Center(
        child: Obx(() {
          return Text('item$index: ${controller.list[index]}');
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.list[index] = controller.list[index] * 2;
        },
        child: const Icon(Icons.track_changes),
      ),
    );
  }
}
