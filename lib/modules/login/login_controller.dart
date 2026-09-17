import 'package:flutter/widgets.dart';
import 'package:flutter_project_base/app/controller/user_controller.dart';
import 'package:flutter_project_base/core/network/api/api_service.dart';
import 'package:flutter_project_base/core/network/http/base_result.dart';
import 'package:flutter_project_base/core/storage/storage_util.dart';
import 'package:flutter_project_base/core/utils/loading_dialog_util.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/core/utils/toast_util.dart';
import 'package:flutter_project_base/data/models/user_info.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LoginController extends GetxController 
  with GetTickerProviderStateMixin {
  final UserController userController = Get.find<UserController>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;//是否显示密码
  final usernameError = ''.obs;
  final passwordError = ''.obs;
  final rememberPassword = false.obs;

  void toggleObscure() => _obscurePassword.value = !_obscurePassword.value;
  bool validate() {
    usernameError.value = _usernameController.text.isEmpty ? '请输入用户名' : '';
    passwordError.value = _passwordController.text.isEmpty ? '请输入密码' : '';
    return usernameError.isEmpty && passwordError.isEmpty;
  }
  
    late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

        // 控制器初始化时调用
    // 适合：初始化变量、监听 Worker、绑定数据
  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }
  
 // 第一帧渲染完成后调用
    // 适合：弹 SnackBar/Dialog、页面跳转、依赖 UI 的初始化
  @override
  void onReady() {
    super.onReady();
  }
  // 控制器被销毁时调用
    // 适合：关闭 StreamController、取消 Timer、释放资源
  @override
  void onClose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.onClose();
  }

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
  
  void _handleLogin() async {
      usernameError.value = '';
      passwordError.value = '';
     if (validate()) return;
      await userController.login(_usernameController.text.trim(), _passwordController.text.trim());
  }
}
