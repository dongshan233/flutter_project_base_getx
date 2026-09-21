import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_base/app/controller/user_controller.dart';
import 'package:flutter_project_base/app/routes/app_routes.dart';
import 'package:flutter_project_base/core/network/api/api_service.dart';
import 'package:flutter_project_base/core/network/http/base_result.dart';
import 'package:flutter_project_base/core/utils/loading_dialog_util.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/core/utils/toast_util.dart';
import 'package:flutter_project_base/data/models/collect_article_info.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late WebViewController _webViewController;
  late UserController _userController;

  var title = '';
  var link = '';
  var originId = 0;
  var isCollect = false;

  var _progress = 0;
  @override
  void initState() {
    super.initState();
    final articleInfo = RouteUtils.getArgument() as Map<String, dynamic>;
    title = articleInfo['title'] ?? "";
    link = articleInfo['link'] ?? '';
    originId = articleInfo['originId'] ?? 0;
    isCollect = articleInfo['collect'] ?? false;

    _userController = Get.find<UserController>();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _progress = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _progress = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _progress = 100;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_progress < 100)
              LinearProgressIndicator(
                // 进度条高度
                minHeight: 1,
                // 进度条颜色
                valueColor: AlwaysStoppedAnimation(Colors.red),
                // 进度条背景颜色
                backgroundColor: Colors.grey.shade200,
                value: _progress / 100,
              ),
            Expanded(child: WebViewWidget(controller: _webViewController)),
          ],
        ),
      ),
    );
  }

  // 顶部返回按钮
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            RouteUtils.back();
          },
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black87),
        ),
        Text(
          "文章详情",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Expanded(child: SizedBox()),
        IconButton(
          onPressed: () async {
            // 先判断是否登录
            if (_userController.isLogin) {
              // 已登录，继续执行收藏操作
              // 收藏功能
              LoadingDialogUtil.showDuring<BaseResult<CollectArticleInfo>>(
                context,
                () async {
                  final result = await ApiService().addCollectArticle(originId);
                  if (result.isSuccess) {
                    // 收藏成功
                    ToastUtil.show('收藏成功');
                    setState(() {
                      isCollect = true;
                    });
                  } else {
                    // 收藏失败
                    ToastUtil.show(result.errorMsg);
                  }
                  return result;
                },
              );
            } else {
              // 未登录，跳转到登录页
              RouteUtils.to(AppRoutes.login);
              return;
            }
          },
          icon: Icon(
            isCollect ? Icons.favorite : Icons.favorite_outline,
            size: 24,
            color: Colors.red,
          ),
        ),
        IconButton(
          onPressed: () {
            // 更多功能
          },
          icon: const Icon(Icons.share, size: 24, color: Colors.black87),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
