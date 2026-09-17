import 'package:flutter_project_base/modules/login/login_controller.dart';
import 'package:get/get.dart';

class Loginbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
