import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
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
            suffixIcon: controller.searchTextLength.value > 0
                ? IconButton(
                    onPressed: () {
                      controller.searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear_rounded,
                    ),
                  )
                : null,
            prefixIcon: controller.settingController.isPremium.value &&
                    !controller.settingController.isSafeContentOnly.value
                ? IconButton(
                    icon: Obx(
                      () => Icon(
                        Icons.health_and_safety_outlined,
                        color: controller.suggestSFW.value
                            ? Colors.black87
                            : Colors.red[400],
                      ),
                    ),
                    onPressed: controller.toggleSuggestSFW,
                  )
                : const Icon(
                    Icons.search,
                    color: Colors.black87,
                  ),
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
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSfwSuggestionsPart(),
                  ],
                ),
              ),
      ),
    );
  }

  ListView _buildSfwSuggestionsPart() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        String subreddit = controller.suggestions.toList()[index];
        return Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => controller.onSuggestionsTap(subreddit),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.black38,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      subreddit,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      controller.searchController.text = subreddit;
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      itemCount: controller.suggestions.length,
    );
  }
}
