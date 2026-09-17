import 'package:flutter_project_base/app/controller/user_controller.dart';
import 'package:flutter_project_base/core/network/api/api_service.dart';
import 'package:flutter_project_base/core/network/http/base_result.dart';
import 'package:flutter_project_base/core/storage/storage_util.dart';
import 'package:flutter_project_base/core/utils/loading_dialog_util.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/core/utils/toast_util.dart';
import 'package:flutter_project_base/data/models/user_info.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LoginController extends GetxController {
  final UserController userController = Get.find<UserController>();
  //登录
  Future<void> login(String username, String password) async {
    try {
      await LoadingDialogUtil.showDuring<BaseResult<UserInfo>>(
        Get.context!,
        () async {
          final currentUserInfo = await ApiService().login(
            params: {'username': username, 'password': password},
          );
          if (currentUserInfo.isSuccess) {
            ToastUtil.show('登录成功,欢迎回来，$username！');
            final userInfo = currentUserInfo.data!;

            // 1. 更新全局用户信息
            userController.userInfo = userInfo;

            // 记住密码
            StorageUtil.setString(StorageKey.loginUsername, username);
            StorageUtil.setString(StorageKey.loginPassword, password);
            RouteUtils.back();
          } else {
            ToastUtil.showError(currentUserInfo.errorMsg);
          }
          return currentUserInfo;
        },
      );
    } catch (e) {
      // 显示toast
      ToastUtil.show(e.toString());
    }
  }
}
