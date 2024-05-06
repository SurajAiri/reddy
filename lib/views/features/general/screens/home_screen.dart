import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/views/features/general/widgets/post_field.dart';
import 'package:reddy/views/widgets/red_lottie_anim.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/home_drawer.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            controller.scaffoldKey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                AssetPaths.img.logo,
                height: 32,
                // width: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: const Text(
          'Reddy',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AllRoutes.searchScreen);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print("Icons.reddit");
            },
            icon: const Icon(Icons.reddit),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: RedLottieAnim(path: AssetPaths.lottie.loading),
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    if (index < controller.posts.value!.posts.length) {
                      return VisibilityDetector(
                        key: Key(index.toString()),
                        onVisibilityChanged: (visibilityInfo) {
                          if (visibilityInfo.visibleFraction == 1) {
                            controller.settings.focusPostId.value =
                                controller.posts.value!.posts[index].id;
                          }
                        },
                        child: PostField(
                          post: controller.posts.value!.posts[index],
                          safeContentOnly: controller.isSafeContentOnly.value,
                          imageQuality: controller.imageQuality.value,
                          postUrlPressed: () => controller.postLinkClicked(
                              controller.posts.value!.posts[index].url),
                        ),
                      );
                    }

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: controller.nextPage,
                        child: const Text("Load More..."),
                      ),
                    );
                  },
                  itemCount: controller.postCount.value,
                ),
        ),
      ),
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
}
