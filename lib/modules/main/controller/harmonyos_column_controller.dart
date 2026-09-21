import 'package:flutter_project_base/core/base/base_controller.dart';
import 'package:flutter_project_base/core/network/api/api_service.dart';
import 'package:flutter_project_base/data/models/harmony_column_info.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

class HarmonyosColumnController extends BaseController<HarmonyosColumn> {
  RxInt currentIndex = 0.obs;
  int get currentIndexValue => currentIndex.value;
  set currentIndexValue(int value) => currentIndex.value = value;

  /// API Service
  final ApiService apiService = ApiService();
  RxList<String> tabList = <String>[].obs;

  @override
  Future<void> loadData() async {
    setLoading();
    await _getHarmonyosColumnList();
  }

  /// 获取鸿蒙专栏列表
  Future<void> _getHarmonyosColumnList() async {
    try {
      final result = await apiService.getHarmonyosColumnList();
      if (!result.isSuccess) {
        setError(result.errorMsg);
        return;
      }
      final data = result.data;
      if (data == null) {
        setEmpty();
        return;
      }
      tabList.add(data.tools.name);
      tabList.add(data.links.name);
      tabList.add(data.open_sources.name);
      setSuccess(data);
    } catch (e) {
      setError("获取失败");
    }
  }
}
