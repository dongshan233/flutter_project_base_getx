import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final PageController pageController = PageController(initialPage: 0);

  RxInt currentIndex = 0.obs;

  List<BottomNavigationBarItem> items() {
    return [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
      BottomNavigationBarItem(icon: Icon(Icons.article), label: '鸿蒙'),
      BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: '体系'),
      BottomNavigationBarItem(icon: Icon(Icons.menu), label: '项目'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
    ];
  }
}
