import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/controllers/post/reddit_search_controller.dart';
import 'package:reddy/models/subreddits/subreddit_model.dart';
import 'package:reddy/views/widgets/red_lottie_anim.dart';
import 'package:reddy/views/widgets/search_field.dart';

import '../../../../services/subranking/utility.dart';

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
            enabled: !controller.isValidating.value && !controller.isLoadingApiData.value,
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
                    onPressed: controller.isValidating.value || controller.isLoadingApiData.value
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
                ),
              )
            : Column(
                children: [
                  _buildSearchModeSelector(),
                  if (controller.isApiMode) _buildApiControls(),
                  Expanded(
                    child: controller.isLoadingApiData.value
                        ? _buildLoadingIndicator()
                        : _buildSuggestionsList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => controller.switchSearchMode(SearchMode.local),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.isLocalMode ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storage,
                        size: 18,
                        color: controller.isLocalMode ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Local",
                        style: TextStyle(
                          color: controller.isLocalMode ? Colors.white : Colors.black54,
                          fontWeight: controller.isLocalMode ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: controller.canUseApiMode
                    ? () => controller.switchSearchMode(SearchMode.api)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.isApiMode ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud,
                        size: 18,
                        color: controller.canUseApiMode
                            ? (controller.isApiMode ? Colors.white : Colors.black54)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Live",
                        style: TextStyle(
                          color: controller.canUseApiMode
                              ? (controller.isApiMode ? Colors.white : Colors.black54)
                              : Colors.grey,
                          fontWeight: controller.isApiMode ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (!controller.canUseApiMode)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "PRO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                "API Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.refreshApiData,
                icon: const Icon(Icons.refresh, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Type:", style: TextStyle(fontSize: 12)),
                    Obx(
                      () => DropdownButton<SubrankingType>(
                        value: controller.selectedType.value,
                        isExpanded: true,
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateApiSettings(type: value);
                          }
                        },
                        items: SubrankingType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.capitalize!),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Category:", style: TextStyle(fontSize: 12)),
                    Obx(
                      () => DropdownButton<SubrankingCategory>(
                        value: controller.selectedCategory.value,
                        isExpanded: true,
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateApiSettings(category: value);
                          }
                        },
                        items: SubrankingCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryDisplayName(category)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading subreddits..."),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Obx(
      () => controller.suggestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.isLocalMode ? Icons.storage : Icons.cloud_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.isLocalMode 
                        ? "No local subreddits found"
                        : "No subreddits loaded from API",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: controller.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = controller.suggestions[index];
                
                if (suggestion is String) {
                  return _buildLocalSuggestionTile(suggestion);
                } else if (suggestion is SubredditModel) {
                  return _buildApiSuggestionTile(suggestion);
                }
                
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildLocalSuggestionTile(String subreddit) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => controller.onSuggestionsTap(subreddit),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.black38,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  subreddit,
                  style: const TextStyle(
                    color: Colors.black87,
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
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiSuggestionTile(SubredditModel subreddit) {
    return GestureDetector(
      onTap: () => controller.onSuggestionsTap(subreddit),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: subreddit.iconUrl.isNotEmpty 
                  ? NetworkImage(subreddit.iconUrl)
                  : null,
              backgroundColor: Colors.blue[100],
              child: subreddit.iconUrl.isEmpty
                  ? Text(
                      subreddit.name.isNotEmpty ? subreddit.name[0].toUpperCase() : 'R',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'r/${subreddit.name}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_formatSubscriberCount(subreddit.subscribers)} members',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(SubrankingCategory category) {
    switch (category) {
      case SubrankingCategory.sfw:
        return 'SFW';
      case SubrankingCategory.nsfw:
        return 'NSFW';
      case SubrankingCategory.nonVerify:
        return 'Non-Verified';
      case SubrankingCategory.karmaFriendly:
        return 'Karma Friendly';
    }
  }

  String _formatSubscriberCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}