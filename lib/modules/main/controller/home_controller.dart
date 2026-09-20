import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_base/core/base/base_controller.dart';
import 'package:flutter_project_base/core/network/api/api_service.dart';
import 'package:flutter_project_base/core/utils/toast_util.dart';
import 'package:flutter_project_base/data/models/banner_info.dart';
import 'package:flutter_project_base/data/models/home_article.dart';
import 'package:get/get.dart';

class HomeController extends BaseController<List<HomeArticleInfo>> {
  final ScrollController scrollController = ScrollController();

  //Banner列表
  final RxList<BannerInfo> bannerList = <BannerInfo>[].obs;
  //Banner加载状态
  final RxBool bannerLoading = false.obs;

  //Banner错误信息
  final RxString bannerError = ''.obs;

  //文章列表
  final RxList<HomeArticleInfo> homeArticleList = <HomeArticleInfo>[].obs;
  //标题栏透明度
  final RxDouble opacity = 0.0.obs;

  /// EasyRefresh 控制器
  final EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishLoad: true,
    controlFinishRefresh: true,
  );

  /// API Service
  final ApiService apiService = ApiService();

  @override
  Future<void> loadData() async {
    // 主接口开始加载
    setLoading();

    // 两个接口并发执行
    await Future.wait([
      _loadHomeArticleList(updatePageState: true),
      _loadBannerList(),
    ]);
  }

  //主接口：文章
  //首页文章列表
  /// updatePageState:
  /// true  -> 控制页面整体 State
  /// false -> 仅刷新数据，不改变页面整体 State
  /// 下拉刷新不改变state状态，为false
  Future<void> _loadHomeArticleList({required bool updatePageState}) async {
    try {
      final result = await apiService.getHomeArticleList();
      if (!result.isSuccess) {
        const errorMessage = '首页文章加载失败';
        if (updatePageState) {
          setError(errorMessage);
        } else {
          ToastUtil.show(errorMessage);
        }
        return;
      }
      final data = result.data?.datas ?? [];
      homeArticleList.assignAll(data);
      if (data.isEmpty) {
        setEmpty();
      } else {
        setSuccess(data);
      }
    } catch (e) {
      final errorMessage = e.toString();
      if (updatePageState) {
        // 首次加载失败
        // 整个页面进入错误状态
        setError(errorMessage);
      } else {
        // 下拉刷新失败
        // 不要让已有页面突然变成错误页
        ToastUtil.show(errorMessage);
      }
    }
  }

  //次要接口，获取banner
  Future<void> _loadBannerList() async {
    bannerLoading.value = true;
    bannerError.value = '';

    try {
      final result = await apiService.getBannerList();
      if (!result.isSuccess) {
        bannerError.value = 'Banner 加载失败';
        return;
      }
      bannerList.assignAll(result.data ?? []);
    } catch (e) {
      bannerError.value = e.toString();
    } finally {
      bannerLoading.value = false;
    }
  }

  //只重试主接口
  //banner通过自己的重试按钮触发
  @override
  void retry() async {
    setLoading();
    await _loadHomeArticleList(updatePageState: true);
  }

  //banner单独重试
  Future<void> retryBanner() async {
    await _loadBannerList();
  }

  /// 下拉刷新
  ///
  /// 文章 + Banner 并发刷新。
  ///
  /// 文章刷新失败：
  /// 保留当前页面，不切换到错误页，只 Toast。
  ///
  /// Banner 刷新失败：
  /// 只影响 Banner。
  Future<void> refreshData() async {
    await Future.wait([
      _loadHomeArticleList(updatePageState: false),
      _loadBannerList(),
    ]);
  }

  void _scrollListener() {
    if (!scrollController.hasClients) {
      return;
    }

    double newOpacity = scrollController.offset / 100;

    if (newOpacity > 1.0) {
      newOpacity = 1.0;
    }

    if (newOpacity < 0.0) {
      newOpacity = 0.0;
    }

    if (opacity.value != newOpacity) {
      opacity.value = newOpacity;
    }
  }

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);

    scrollController.dispose();
    easyRefreshController.dispose();

    super.onClose();
  }
}
