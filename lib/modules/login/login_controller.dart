import 'package:flutter/widgets.dart';
import 'package:flutter_project_base/app/controller/user_controller.dart';
import 'package:flutter_project_base/app/routes/app_routes.dart';
import 'package:flutter_project_base/core/network/api/api_service.dart';
import 'package:flutter_project_base/core/network/http/base_result.dart';
import 'package:flutter_project_base/core/storage/storage_util.dart';
import 'package:flutter_project_base/core/utils/loading_dialog_util.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/core/utils/toast_util.dart';
import 'package:flutter_project_base/data/models/user_info.dart';
import 'package:get/get.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  final UserController userController = Get.find<UserController>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs; //是否显示密码
  final usernameError = ''.obs;
  final passwordError = ''.obs;
  final rememberPassword = false.obs;

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;
  bool validate() {
    usernameError.value = usernameController.text.isEmpty ? '请输入用户名' : '';
    passwordError.value = passwordController.text.isEmpty ? '请输入密码' : '';
    return usernameError.isEmpty && passwordError.isEmpty;
  }

  late AnimationController _animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // 控制器初始化时调用
  // 适合：初始化变量、监听 Worker、绑定数据
  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
    // 初始化记住密码状态
    rememberPassword.value =
        StorageUtil.getBool(StorageKey.loginRememberPassword) ?? false;
    if (rememberPassword.value) {
      usernameController.text =
          StorageUtil.getString(StorageKey.loginUsername) ?? '';
      passwordController.text =
          StorageUtil.getString(StorageKey.loginPassword) ?? '';
    }
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
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void handleLogin() async {
    usernameError.value = '';
    passwordError.value = '';
    if (!validate()) return;
    await _login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );
  }

  //登录
  Future<void> _login(String username, String password) async {
    try {
      // 1. showDuring 只负责"弹窗 + 请求"
      final result = await LoadingDialogUtil.showDuring<BaseResult<UserInfo>>(
        Get.context!,
        () => ApiService().login(
          params: {'username': username, 'password': password},
        ),
      );

      // 2. 执行到这里时弹窗已经关闭，再处理业务
      if (result == null || !result.isSuccess) {
        ToastUtil.showError(
          result?.errorMsg?.isNotEmpty == true
              ? result!.errorMsg!
              : '登录失败，请检查账号密码',
        );
        return;
      }

      userController.userInfo = result.data!;
      if (rememberPassword.value) {
        StorageUtil.setString(StorageKey.loginUsername, username);
        StorageUtil.setString(StorageKey.loginPassword, password);
      } else {
        StorageUtil.remove(StorageKey.loginUsername);
        StorageUtil.remove(StorageKey.loginPassword);
      }
      ToastUtil.show('登录成功，欢迎回来，$username！');
      RouteUtils.offAll(AppRoutes.home); // 3. 最后跳转，栈里干干净净
    } catch (e) {
      // 显示toast
      ToastUtil.show('登陆异常：$e');
    }
  }
}
