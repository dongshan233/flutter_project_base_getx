import 'package:flutter/material.dart';
import 'package:flutter_project_base/modules/home/home_controller.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('homePage')));
  }
}
