import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

class RedditSearchController extends GetxController {
  final settingController = Get.find<SettingsController>();

  TextEditingController searchController = TextEditingController();
  RxBool isValidating = false.obs;
  RxBool isSearching = false.obs;
  FocusNode searchFocusNode = FocusNode();
  RxInt searchTextLength = 0.obs;

  List<String> allSFWSubreddit = [];
  RxList<String> suggestions = <String>[].obs;
  List<String> allNSFWSubreddit = [];

  RxBool suggestSFW = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSubreddit();

    searchController.addListener(() {
      searchTextLength.value = searchController.text.length;
      _updateSfwSuggestions();
    });
    // searchFocusNode.requestFocus(); // todo: uncomment this
  }

  void validateSearch() async {
    if (searchTextLength.value < 3) return;
    isValidating.value = true;
    bool v = await RedditApi.checkIfSubredditExist(
      searchController.text.trim(),
    );
    isValidating.value = false;
    if (v) {
      Get.back();
      Get.find<HomeController>().updateSubreddit(searchController.text.trim());
    } else {
      UiUtility.showToast("Invalid Subreddit", isError: true);
    }
  }

  // sfw
  void _updateSfwSuggestions() {
    if (searchController.text == "") {
      suggestions.value =
          List.from(suggestSFW.value ? allSFWSubreddit : allNSFWSubreddit);
      return;
    }
    suggestions.clear();
    if (suggestSFW.value) {
      suggestions.addAll(allSFWSubreddit.where((element) =>
          element.toLowerCase().contains(searchController.text.toLowerCase())));
    } else {
      suggestions.addAll(allNSFWSubreddit.where((element) =>
          element.toLowerCase().contains(searchController.text.toLowerCase())));
    }
  }

  Future<void> _loadSubreddit() async {
    allSFWSubreddit =
        await _loadSubredditFromFile(AssetPaths.data.sfwSubreddit);
    allNSFWSubreddit =
        await _loadSubredditFromFile(AssetPaths.data.nsfwSubreddit);
    print("all SFW subreddit length: ${allSFWSubreddit.length}");
    print("all NSFW subreddit length: ${allNSFWSubreddit.length}");
    Future.delayed(const Duration(milliseconds: 750), () {
      _updateSfwSuggestions();
    });
  }

  Future<List<String>> _loadSubredditFromFile(String path) async {
    var fileContent = await rootBundle.loadString(path);

    // Remove square brackets and split the content by commas
    List<String> dataList = fileContent
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',');

    // Trim each string in the list
    return dataList.map((e) => e.trim()).toList();
  }

  void onSuggestionsTap(String subreddit) {
    searchController.text = subreddit;
    validateSearch();
  }

  void toggleSuggestSFW() {
    suggestSFW.value = !suggestSFW.value;
    _updateSfwSuggestions();
  }
}
