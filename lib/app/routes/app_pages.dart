import 'package:flutter_project_base/app/routes/app_routes.dart';
import 'package:flutter_project_base/modules/home/home_binding.dart';
import 'package:flutter_project_base/modules/home/home_page.dart';
import 'package:flutter_project_base/modules/login/loginBinding.dart';
import 'package:flutter_project_base/modules/login/login_page.dart';
import 'package:get/get_navigation/get_navigation.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: Loginbinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
