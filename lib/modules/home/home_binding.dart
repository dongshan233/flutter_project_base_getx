import 'package:flutter_project_base/modules/home/controller/harmonyos_column_controller.dart';
import 'package:flutter_project_base/modules/home/controller/project_menu_controller.dart';
import 'package:flutter_project_base/modules/home/controller/system_controller.dart';
import 'package:flutter_project_base/modules/home/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut(() => HarmonyosColumnController());
    Get.lazyPut(() => SystemController());
    Get.lazyPut(() => ProjectMenuController());
    Get.lazyPut(() => HomeController());
  }
}
