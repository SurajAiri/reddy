import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/controllers/post/reddit_search_controller.dart';
import 'package:reddy/views/widgets/red_lottie_anim.dart';
import 'package:reddy/views/widgets/search_field.dart';

class SearchScreen extends GetView<RedditSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => SearchField(
            focusNode: controller.searchFocusNode,
            hintText: "Enter Subreddit",
            controller: controller.searchController,
            onEditingComplete: controller.validateSearch,
            enabled: !controller.isValidating.value,
          ),
        ),
        actions: [
          Obx(
            () => controller.searchTextLength > 2
                ? IconButton(
                    onPressed: controller.isValidating.value
                        ? null
                        : controller.validateSearch,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                    ),
                    icon: const Icon(
                      Icons.navigate_next_rounded,
                      size: 35,
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(
        () => controller.isValidating.value
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RedLottieAnim(path: AssetPaths.lottie.validation),
                    const SizedBox(height: 4),
                    const Text("Validating Subreddit..."),
                  ],
                ),
              ))
            : const SizedBox(),
      ),
    );
  }
}
