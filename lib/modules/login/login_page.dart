import 'package:flutter/material.dart';
import 'package:flutter_project_base/core/storage/storage_util.dart';
import 'package:flutter_project_base/modules/login/login_controller.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录'), centerTitle: true),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FadeTransition(
              opacity: controller.fadeAnimation,
              child: SlideTransition(
                position: controller.slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 50),
                    _buildUsernameField(),
                    Obx(
                      () => controller.usernameError.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20, top: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  controller.usernameError.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    Obx(
                      () => controller.passwordError.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20, top: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  controller.passwordError.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 10),
                    _buildForgotPassword(),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Colors.white, Color(0xFFf0f0f0)],
            ),
            // boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset('assets/images/ic_logo.png'),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'WanAndroid',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0077f1),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '登录您的账户',
          style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          // boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(
            color: controller.usernameError.value.isNotEmpty
                ? Colors.red
                : Colors.grey[200]!,
          ),
        ),
        child: TextField(
          controller: controller.usernameController,
          onChanged: (value) {
            controller.usernameError.value = '';
          },
          decoration: const InputDecoration(
            hintText: '请输入用户名',
            prefixIcon: Icon(Icons.person, color: Color(0xFF999999)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          // boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(
            color: controller.passwordError.value.isNotEmpty
                ? Colors.red
                : Colors.grey[200]!,
          ),
        ),
        child: TextField(
          controller: controller.passwordController,
          onChanged: (value) {
            controller.passwordError.value = '';
          },
          obscureText: controller.obscurePassword.value,
          decoration: InputDecoration(
            hintText: '请输入密码',
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF999999)),
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF999999),
              ),
              onPressed: () {
                controller.toggleObscure();
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      children: [
        Row(
          children: [
            Obx(
              () => Checkbox(
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Color(0xFF0077f1)
                      : Colors.grey[200]!,
                ),
                value: controller.rememberPassword.value,
                onChanged: (value) {
                  StorageUtil.setBool(
                    StorageKey.loginRememberPassword,
                    value ?? false,
                  );
                  controller.rememberPassword.value = value ?? false;
                },
              ),
            ),

            Text(
              "记住密码",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              "忘记密码？",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0077f1), Color(0xFF0077f1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077f1).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: controller.handleLogin,
        child: const Text(
          '登 录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('还没有账号？', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        TextButton(
          onPressed: () {
            // RouteUtils.to(AppRoutes.register);
          },
          child: const Text(
            '立即注册',
            style: TextStyle(
              color: Color(0xFF0077f1),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
