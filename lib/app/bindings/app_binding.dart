import 'package:flutter_project_base/app/controller/user_controller.dart';
import 'package:get/instance_manager.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(
      UserController(),
      permanent: true,
    ); //全局controller不销毁
  }
}
