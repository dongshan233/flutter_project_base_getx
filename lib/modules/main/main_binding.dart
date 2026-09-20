import 'package:flutter_project_base/modules/main/controller/harmonyos_column_controller.dart';
import 'package:flutter_project_base/modules/main/controller/home_controller.dart';
import 'package:flutter_project_base/modules/main/controller/project_menu_controller.dart';
import 'package:flutter_project_base/modules/main/controller/system_controller.dart';
import 'package:get/get.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut(() => HarmonyosColumnController());
    Get.lazyPut(() => SystemController());
    Get.lazyPut(() => ProjectMenuController());
    Get.lazyPut(() => HomeController());
  }
}
