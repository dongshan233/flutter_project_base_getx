import 'package:flutter/material.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/core/utils/toast_util.dart';
import 'package:flutter_project_base/modules/main/main_controller.dart';
import 'package:flutter_project_base/modules/main/nav/harmonyos_column_widget.dart';
import 'package:flutter_project_base/modules/main/nav/home_widget.dart';
import 'package:flutter_project_base/widgets/double_back_exit_widget.dart';
import 'package:get/get.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DoubleBackExitWidget(
      onDoubleBack: () {
        RouteUtils.back();
      },
      onSingleBack: () {
        ToastUtil.show('再按一次退出！');
      },
      child: Scaffold(
        body: PageView(
          controller: controller.pageController,
          //禁用页面切换动画
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeWidget(),
            HarmonyosColumnWidget(),
            HarmonyosColumnWidget(),
            HarmonyosColumnWidget(),
            HarmonyosColumnWidget(),
          ],
          onPageChanged: (index) {
            controller.currentIndex.value = index;
          },
        ),
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
            items: controller.items(),
            currentIndex: controller.currentIndex.value,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xFF0077f1),
            unselectedItemColor: Color(0xFF999999),
            backgroundColor: Colors.white,
            onTap: (index) {
              controller.currentIndex.value = index;
              controller.pageController.jumpToPage(index);
            },
          );
        }),
      ),
    );
  }
}
