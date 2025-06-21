import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';
import 'package:reddy/services/subranking/subranking_api.dart';
import 'package:reddy/models/subreddits/subreddit_model.dart';

import '../../services/subranking/utility.dart';

enum SearchMode {
  local,
  api,
}

class RedditSearchController extends GetxController {
  final settingController = Get.find<SettingsController>();

  TextEditingController searchController = TextEditingController();
  RxBool isValidating = false.obs;
  RxBool isSearching = false.obs;
  RxBool isLoadingApiData = false.obs;
  FocusNode searchFocusNode = FocusNode();
  RxInt searchTextLength = 0.obs;

  // Local data
  List<String> allSFWSubreddit = [];
  List<String> allNSFWSubreddit = [];
  
  // API data
  RxList<SubredditModel> apiSubreddits = <SubredditModel>[].obs;
  
  // Current suggestions based on mode
  RxList<dynamic> suggestions = <dynamic>[].obs; // Can be String or SubredditModel
  
  RxBool suggestSFW = true.obs;
  Rx<SearchMode> currentSearchMode = SearchMode.local.obs;
  
  // API settings
  Rx<SubrankingType> selectedType = SubrankingType.largest.obs;
  Rx<SubrankingCategory> selectedCategory = SubrankingCategory.sfw.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalSubreddits();

    searchController.addListener(() {
      searchTextLength.value = searchController.text.length;
      _updateSuggestions();
    });
    
    // Load API data for premium users by default
    if (settingController.isPremium.value) {
      _loadApiSubreddits();
    }
  }

  void validateSearch() async {
    if (searchTextLength.value < 3) return;
    isValidating.value = true;
    
    String subredditName = searchController.text.trim();
    
    // Remove 'r/' prefix if present
    if (subredditName.startsWith('r/')) {
      subredditName = subredditName.substring(2);
    }
    
    bool isValid = await RedditApi.checkIfSubredditExist(subredditName);
    isValidating.value = false;
    
    if (isValid) {
      Get.back();
      Get.find<HomeController>().updateSubreddit(subredditName);
    } else {
      UiUtility.showToast("Invalid Subreddit", isError: true);
    }
  }

  void _updateSuggestions() {
    if (currentSearchMode.value == SearchMode.local) {
      _updateLocalSuggestions();
    } else {
      _updateApiSuggestions();
    }
  }

  void _updateLocalSuggestions() {
    if (searchController.text.isEmpty) {
      suggestions.value = List<String>.from(
        suggestSFW.value ? allSFWSubreddit : allNSFWSubreddit
      );
      return;
    }
    suggestions.clear();
    List<String> sourceList = suggestSFW.value ? allSFWSubreddit : allNSFWSubreddit;
    
    suggestions.addAll(
      sourceList.where((element) =>
        element.toLowerCase().contains(searchController.text.toLowerCase())
      ).take(20) // Limit to 20 suggestions
    );
  }

  void _updateApiSuggestions() {
    if (searchController.text.isEmpty) {
      suggestions.value = List<SubredditModel>.from(apiSubreddits);
      return;
    }
    
    suggestions.clear();
    suggestions.addAll(
      apiSubreddits.where((subreddit) =>
        subreddit.name.toLowerCase().contains(searchController.text.toLowerCase())
      ).take(20) // Limit to 20 suggestions
    );
  }

  Future<void> _loadLocalSubreddits() async {
    allSFWSubreddit = await _loadSubredditFromFile(AssetPaths.data.sfwSubreddit);
    allNSFWSubreddit = await _loadSubredditFromFile(AssetPaths.data.nsfwSubreddit);
    
    print("Local SFW subreddit length: ${allSFWSubreddit.length}");
    print("Local NSFW subreddit length: ${allNSFWSubreddit.length}");
    
    Future.delayed(const Duration(milliseconds: 750), () {
      if (currentSearchMode.value == SearchMode.local) {
        _updateSuggestions();
      }
    });
  }

  Future<void> _loadApiSubreddits() async {
    if (!settingController.isPremium.value) return;
    
    isLoadingApiData.value = true;
    
    try {
      List<SubredditModel> fetchedSubreddits = await SubrankingApi.fetchSubredditNames(
        type: selectedType.value,
        category: selectedCategory.value,
        nsfw: !suggestSFW.value,
        limit: 100,
      );
      
      apiSubreddits.value = fetchedSubreddits;
      
      if (currentSearchMode.value == SearchMode.api) {
        _updateSuggestions();
      }
      
      print("API subreddits loaded: ${apiSubreddits.length}");
    } catch (e) {
      print("Error loading API subreddits: $e");
      UiUtility.showToast("Failed to load subreddits from API", isError: true);
    } finally {
      isLoadingApiData.value = false;
    }
  }

  Future<List<String>> _loadSubredditFromFile(String path) async {
    var fileContent = await rootBundle.loadString(path);

    List<String> dataList = fileContent
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',');

    return dataList.map((e) => e.trim()).toList();
  }

  void onSuggestionsTap(dynamic suggestion) {
    String subredditName;
    
    if (suggestion is String) {
      subredditName = suggestion;
    } else if (suggestion is SubredditModel) {
      subredditName = suggestion.name;
    } else {
      return;
    }
    
    searchController.text = subredditName;
    validateSearch();
  }

  void toggleSuggestSFW() {
    suggestSFW.value = !suggestSFW.value;
    
    if (currentSearchMode.value == SearchMode.api) {
      _loadApiSubreddits(); // Reload with new NSFW setting
    } else {
      _updateSuggestions();
    }
  }

  void switchSearchMode(SearchMode mode) {
    if (!settingController.isPremium.value && mode == SearchMode.api) {
      UiUtility.showToast("Premium feature", isError: true);
      return;
    }
    
    currentSearchMode.value = mode;
    
    if (mode == SearchMode.api && apiSubreddits.isEmpty) {
      _loadApiSubreddits();
    } else {
      _updateSuggestions();
    }
  }

  void updateApiSettings({
    SubrankingType? type,
    SubrankingCategory? category,
  }) {
    bool shouldReload = false;
    
    if (type != null && type != selectedType.value) {
      selectedType.value = type;
      shouldReload = true;
    }
    
    if (category != null && category != selectedCategory.value) {
      selectedCategory.value = category;
      shouldReload = true;
    }
    
    if (shouldReload && currentSearchMode.value == SearchMode.api) {
      _loadApiSubreddits();
    }
  }

  void refreshApiData() {
    if (currentSearchMode.value == SearchMode.api) {
      _loadApiSubreddits();
    }
  }

  // Helper methods for UI
  bool get isLocalMode => currentSearchMode.value == SearchMode.local;
  bool get isApiMode => currentSearchMode.value == SearchMode.api;
  bool get canUseApiMode => settingController.isPremium.value;
  
  String getSearchModeTitle() {
    switch (currentSearchMode.value) {
      case SearchMode.local:
        return "Local Database";
      case SearchMode.api:
        return "Live Data";
    }
  }
}