import 'package:get/get.dart';
import 'package:simulator/app/core/basebluetoothcontroller.dart';

class HomeController extends BaseBluetoothController {
  //TODO: Implement HomeController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
