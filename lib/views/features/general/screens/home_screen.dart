import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/asset_paths.dart';
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
      // appBar: _buildAppbar(),
      // body: _buildBody(),
      body: buildMainBody(context),
      drawer: const HomeDrawer(),
      // floatingActionButton: Obx(
      //   () => controller.settings.isPremium.value
      //       ? FloatingActionButton(
      //           onPressed: controller.floatingButtonAction,
      //           backgroundColor: Colors.red[300],
      //           child: const Icon(
      //             Icons.replay_outlined,
      //             color: Colors.white,
      //           ),
      //         )
      //       : const SizedBox(),
      // ),
    );
  }

  SafeArea _buildBody() {
    return SafeArea(
      child: Obx(
        () => controller.isLoading.value
            ? Center(
                child: RedLottieAnim(path: AssetPaths.lottie.loading),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index < controller.posts.value!.posts.length) {
                    return Obx(
                      () => PostField(
                        key: Key(controller.posts.value!.posts[index].id),
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
    );
  }

  Widget buildMainBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: controller.postScrollController,
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
                              title: controller.quickOptions.toList()[index],
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
                  // IconButton(
                  //   onPressed: () {
                  //     print("Icons.reddit");
                  //   },
                  //   icon: const Icon(Icons.reddit),
                  // ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildBody(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // buildAdWidget(),
      ],
    );
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
