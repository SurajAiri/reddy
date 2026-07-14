import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/views/features/general/widgets/post_field.dart';
import 'package:reddy/views/widgets/red_lottie_anim.dart';
import '../widgets/home_drawer.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: buildMainBody(context),
      drawer: const HomeDrawer(),
      floatingActionButton: Obx(
        () => controller.settings.isPremium.value
            ? FloatingActionButton(
                onPressed: controller.floatingButtonAction,
                backgroundColor: Colors.red[300],
                child: const Icon(
                  Icons.replay_outlined,
                  color: Colors.white,
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  Widget buildMainBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: CustomScrollView(
              controller: controller.postScrollController,
              // Needed so pull-to-refresh still works even when the
              // feed is short enough to not fill the screen.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.red[50],
                  bottom: PreferredSize(
                    preferredSize: const Size(0, 30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: SingleChildScrollView(
                        controller: controller.quickOptionScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              controller.quickOptions.length,
                              (index) => QuickButton(
                                isSelected: index == 0,
                                title:
                                    controller.quickOptions.toList()[index],
                                onPressed: controller.updateSubreddit,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  floating: true,
                  leading: InkWell(
                    onTap: () {
                      controller.scaffoldKey.currentState!.openDrawer();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        AssetPaths.img.logo,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  title: Obx(
                    () => Text(
                      controller.feedTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  actions: [
                    _buildSortButton(),
                    IconButton(
                      onPressed: () {
                        Get.toNamed(AllRoutes.searchScreen);
                      },
                      icon: const Icon(Icons.search),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                Obx(() {
                  if (controller.isLoading.value && controller.posts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: RedLottieAnim(path: AssetPaths.lottie.loading),
                      ),
                    );
                  }

                  if (controller.posts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              "No posts found for ${controller.feedTitle}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: SliverList.builder(
                      // True lazy building: unlike the previous
                      // ListView-inside-CustomScrollView setup, each
                      // post is only built when it's about to become
                      // visible, and this is what the scroll listener
                      // in HomeController watches to auto-fetch more
                      // pages (real infinite scroll instead of a
                      // manual "Load more" button).
                      itemCount:
                          controller.posts.length + 1, // +1 = footer
                      itemBuilder: (context, index) {
                        if (index >= controller.posts.length) {
                          return _buildFooter();
                        }
                        final post = controller.posts[index];
                        return Obx(
                          () => PostField(
                            key: Key(post.id),
                            post: post,
                            safeContentOnly:
                                controller.isSafeContentOnly.value,
                            imageQuality: controller.imageQuality.value,
                            postUrlPressed: () =>
                                controller.postLinkClicked(post.url),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    const sortOptions = [
      RedditSortType.best,
      RedditSortType.hot,
      RedditSortType.new_,
      RedditSortType.top,
      RedditSortType.rising,
    ];

    return Obx(
      () => PopupMenuButton<RedditSortType>(
        tooltip: 'Sort by',
        initialValue: controller.currentSort.value,
        onSelected: controller.changeSort,
        itemBuilder: (context) => sortOptions
            .map(
              (sort) => PopupMenuItem(
                value: sort,
                child: Row(
                  children: [
                    Icon(
                      Utility.sortTypeIcon(sort),
                      size: 18,
                      color: sort == controller.currentSort.value
                          ? Colors.red[300]
                          : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(Utility.sortTypeDisplayName(sort)),
                  ],
                ),
              ),
            )
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Utility.sortTypeIcon(controller.currentSort.value),
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (!controller.hasMore.value && controller.posts.isNotEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              "You've reached the end",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      return const SizedBox(height: 24);
    });
  }
}

class QuickButton extends StatelessWidget {
  const QuickButton({
    super.key,
    this.isSelected = false,
    required this.title,
    required this.onPressed,
  });
  final bool isSelected;
  final Function(String value) onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : Colors.red[300],
          foregroundColor: isSelected ? Colors.red[300] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected
                ? BorderSide(
                    color: Colors.red[300]!,
                    width: 1,
                  )
                : BorderSide.none,
          ),
          minimumSize: const Size(48, 0),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
        onPressed: () => onPressed(title),
        child: Text(title),
      ),
    );
  }
}
