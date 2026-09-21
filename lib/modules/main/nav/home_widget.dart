import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_base/app/routes/app_routes.dart';
import 'package:flutter_project_base/core/utils/route_utils.dart';
import 'package:flutter_project_base/data/models/home_article.dart';
import 'package:flutter_project_base/modules/main/controller/home_controller.dart';
import 'package:flutter_project_base/utils/string_util.dart';
import 'package:flutter_project_base/widgets/loading_error_widget.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

//AutomaticKeepAliveClientMixin 只能混入 StatefulWidget 对应的 State 类中
//而 GetView<HomeController> 本质是一个 StatelessWidget
//所以该页面不用getView
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with AutomaticKeepAliveClientMixin {
  final HomeController _homeController = Get.find<HomeController>();
  int currentIndex = 0;
  @override
  bool get wantKeepAlive => true;

  Widget _buildLoading() {
    return const Center(child: CupertinoActivityIndicator());
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('暂无文章', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildError(String error) {
    return LoadingErrorWidget(error: error, retry: _homeController.retry);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //向父布局申请保活
    return _homeController.obx(
      (articleList) {
        return _buildSucess(articleList!);
      },
      onLoading: _buildLoading(),
      onError: (error) {
        return _buildError(error ?? '首页加载失败');
      },
      onEmpty: _buildEmpty(),
    );
  }

  Widget _buildSucess(List<HomeArticleInfo> articleList) {
    return EasyRefresh.builder(
      controller: _homeController.easyRefreshController,
      refreshOnStart: false, //basecontroller已执行首次加载
      onRefresh: () async {
        try {
          await _homeController.refreshData();
        } finally {
          _homeController.easyRefreshController.finishRefresh();
        }
      },
      childBuilder: (context, physics) {
        return Stack(
          children: [
            CustomScrollView(
              controller: _homeController.scrollController,
              physics: physics,
              slivers: [
                //banner
                _bannerList(),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                _homeArticleList(articleList),
                // 底部文案
                if (articleList.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          '我是有底线的~',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            //顶部透明渐变栏
            Obx(() {
              final opacity = _homeController.opacity.value;
              return Container(
                padding: const EdgeInsets.only(top: 45, left: 16),
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: opacity),
                  boxShadow: opacity > 0.5
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'wanAndroid',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87.withValues(alpha: opacity),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  //文章列表
  Widget _homeArticleList(List<HomeArticleInfo> articleList) {
    return SliverToBoxAdapter(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: articleList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final article = articleList[index];
          return InkWell(
            onTap: () {
              RouteUtils.to(
                AppRoutes.webview,
                arguments: {
                  "link": article.link,
                  "title": article.title,
                  "originId": article.id,
                  "isCollect": article.collect,
                },
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      StringUtil.removeMdash(article.title),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // 描述
                    if (article.desc.isNotEmpty)
                      Text(
                        StringUtil.removeMdash(article.desc),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (article.desc.isNotEmpty) const SizedBox(height: 12),

                    // 分类 + 时间
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${article.superChapterName}/${article.chapterName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          article.niceDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //banner
  //自己管理loading/error/empty/success
  Widget _bannerList() {
    return SliverToBoxAdapter(
      child: Obx(() {
        //1Banner加载中
        if (_homeController.bannerLoading.value) {
          return const SizedBox(
            height: 120,
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        //2. Banner加载失败
        if (_homeController.bannerError.value.isNotEmpty) {
          return SizedBox(
            height: 120,
            child: Center(
              child: LoadingErrorWidget(
                error: _homeController.bannerError.value,
                retry: _homeController.retryBanner,
              ),
            ),
          );
        }

        //3. Banner为空
        if (_homeController.bannerList.isEmpty) {
          return SizedBox(
            height: 120,
            child: Center(
              child: Text('暂无Banner', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        //4. Banner成功
        return Stack(
          children: [
            _buildBannerContent(),
            Positioned(bottom: 10, left: 0, right: 0, child: _indicatorList()),
          ],
        );
      }),
    );
  }

  Widget _buildBannerContent() {
    return CarouselSlider(
      items: _homeController.bannerList
          .map(
            (e) => Image.network(
              e.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('图片加载失败'),
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: 210,
        autoPlay: true,
        aspectRatio: 2.0,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          if (!mounted) {
            return;
          }
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _indicatorList() {
    final bannerCount = _homeController.bannerList.length;
    if (bannerCount <= 1) {
      return SizedBox.shrink();
    }
    final safeIndex = currentIndex >= bannerCount ? 0 : currentIndex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        bannerCount,
        (index) => Container(
          width: 20,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: safeIndex == index
                ? const Color(0xFF0077f1)
                : Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
