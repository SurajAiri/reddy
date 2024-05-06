import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
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
              controller.fetchPosts();
            },
            icon: Icon(Icons.replay_outlined),
          ),
          Obx(
            () => IconButton(
              onPressed: () {
                controller.settings.isSafeContentOnly.value =
                    !controller.settings.isSafeContentOnly.value;
              },
              icon: Icon(controller.settings.isSafeContentOnly.value
                  ? Icons.no_accounts
                  : Icons.safety_check),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: RedLottieAnim(path: AssetPaths.lottie.loading),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return PostField(
                            post: controller.posts.value!.posts[index],
                            safeContentOnly: controller.isSafeContentOnly.value,
                            imageQuality: controller.imageQuality.value,
                            postUrlPressed: () => controller.postLinkClicked(
                                controller.posts.value!.posts[index].url),
                          );
                        },
                        itemCount: controller.posts.value?.posts.length ?? 0,
                      ),
                      TextButton(
                        onPressed: controller.nextPage,
                        child: const Text("Load More..."),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      drawer: const HomeDrawer(),
      floatingActionButton: Obx(
        () => controller.settings.isPremium.value
            // () => true
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
