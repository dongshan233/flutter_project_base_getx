import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_base/app/routes/app_routes.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/data/models/harmony_column_info.dart';
import 'package:flutter_project_base/modules/main/controller/harmonyos_column_controller.dart';
import 'package:flutter_project_base/utils/string_util%20copy.dart';
import 'package:flutter_project_base/widgets/loading_empty.dart';
import 'package:flutter_project_base/widgets/loading_error_widget.dart';
import 'package:flutter_project_base/widgets/loading_widget.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/instance_manager.dart';

class HarmonyosColumnWidget extends StatefulWidget {
  const HarmonyosColumnWidget({super.key});

  @override
  State<HarmonyosColumnWidget> createState() => _HarmonyosColumnWidgetState();
}

class _HarmonyosColumnWidgetState extends State<HarmonyosColumnWidget> {
  final HarmonyosColumnController _harmonyosColumnController =
      Get.find<HarmonyosColumnController>();
  @override
  Widget build(BuildContext context) {
    return _harmonyosColumnController.obx(
      (harmonyosColumn) {
        return _buildSuccess(harmonyosColumn!);
      },
      onLoading: const LoadingWidget(),
      onError: (error) {
        return LoadingErrorWidget(
          error: error ?? '数据加载失败',
          retry: _harmonyosColumnController.retry,
        );
      },
      onEmpty: LoadingEmpty(),
    );
  }

  Widget _buildSuccess(HarmonyosColumn harmonyosColumn) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // 标签栏
          _tabList(),
          const SizedBox(height: 12),
          // 文章列表
          Expanded(
            child: _articleList(
              _harmonyosColumnController.currentIndexValue,
              harmonyosColumn.tools,
              harmonyosColumn.links,
              harmonyosColumn.open_sources,
            ),
          ),
        ],
      ),
    );
  }

  /// 封装标签栏
  Widget _tabList() {
    return Row(
      children: [
        for (int i = 0; i < _harmonyosColumnController.tabList.length; i++)
          GestureDetector(
            onTap: () {
              _harmonyosColumnController.currentIndexValue = i;
            },
            child: Container(
              margin: i == 0
                  ? const EdgeInsets.symmetric(horizontal: 10)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _harmonyosColumnController.currentIndexValue == i
                    ? Color(0xFF0077f1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                StringUtil.removeHarmonyosDevPrefix(
                  _harmonyosColumnController.tabList[i],
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _harmonyosColumnController.currentIndexValue == i
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 文章列表
  Widget _articleList(
    int currentIndex,
    HarmonyosColumnTools tools,
    HarmonyosColumnLinks links,
    HarmonyosColumnOpenSources openSources,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: currentIndex == 0
            ? tools.articleList.length
            : currentIndex == 1
            ? links.articleList.length
            : openSources.articleList.length,
        itemBuilder: (context, index) {
          return _articleItem(
            currentIndex == 0
                ? tools.articleList[index]
                : currentIndex == 1
                ? links.articleList[index]
                : openSources.articleList[index],
          );
        },
      ),
    );
  }

  /// 文章项
  Widget _articleItem(HarmonyosColumnArticle article) {
    return InkWell(
      onTap: () {
        // 跳转到webview页面
        // RouteUtils.to(
        //   AppRoutes.webview,
        //   arguments: {
        //     "link": article.link,
        //     "title": article.chapterName,
        //     "originId": article.id,
        //     "collect": article.collect,
        //   },
        // );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文章作者
              Text(
                StringUtil.removeMdash(article.author),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 文章描述
              if (article.desc.isNotEmpty)
                Text(
                  StringUtil.removeMdash(article.desc),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (article.desc.isNotEmpty) const SizedBox(height: 12),
              // 文章信息：分类和时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 分类信息
                  Text(
                    '${article.superChapterName}/${article.chapterName}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  // 发布时间
                  Text(
                    article.niceDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
