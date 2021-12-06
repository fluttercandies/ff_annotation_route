import 'package:example_getx/src/controller/controller1.dart';
import 'package:get/get.dart';

class Bindings1 extends Bindings {
  @override
  void dependencies() {
    Get.put(GetxController1());
  }
}
