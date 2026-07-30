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
import 'package:reddy/services/subranking/subranking_cache_sevice.dart';

import '../../services/subranking/utility.dart';

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
  RxList<dynamic> suggestions =
      <dynamic>[].obs; // Can be String or SubredditModel

  RxBool suggestSFW = true.obs;
  Rx<SearchMode> currentSearchMode = SearchMode.local.obs;

  /// Mirrors whether the search text currently starts with `r/`.
  /// Kept in sync in both directions:
  ///  - typing `r/` (or removing it) updates this toggle automatically.
  ///  - tapping the toggle adds/removes the `r/` prefix from the text.
  /// Starts `false`, matching the blank search field.
  RxBool isSubredditToggle = false.obs;
  bool _isSyncingSubredditPrefix = false;

  // API settings
  Rx<SubrankingType> selectedType = SubrankingType.largest.obs;
  Rx<SubrankingCategory> selectedCategory = SubrankingCategory.sfw.obs;

  @override
  void onInit() {
    super.onInit();

    initSearchTypes();

    // Load API data for premium users by default
    if (!settingController.isPremium.value ||
        currentSearchMode.value == SearchMode.local) {
      _loadLocalSubreddits();
    } else if (settingController.isPremium.value &&
        currentSearchMode.value == SearchMode.api) {
      _loadApiSubreddits();
    }

    searchController.addListener(() {
      searchTextLength.value = searchController.text.length;
      _syncSubredditToggleFromText();
      _updateSuggestions();
    });
  }

  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void updateSearchTypes() {
    settingController.selectedSubrankingType = selectedType.value;
    settingController.selectedSubrankingCategory = selectedCategory.value;
    settingController.currentSearchMode = currentSearchMode.value;
  }

  void initSearchTypes() {
    currentSearchMode.value = settingController.currentSearchMode;
    selectedType.value = settingController.selectedSubrankingType;
    selectedCategory.value = settingController.selectedSubrankingCategory;

  }

  /// `r/<name>` (any amount of internal whitespace is stripped, since
  /// subreddit names can't contain spaces) is treated as a direct jump
  /// to that subreddit, exactly like before. Anything else is treated
  /// as a normal, site-wide reddit search query instead.
  void validateSearch() async {
    if (searchTextLength.value < 3) return;

    String rawText = searchController.text.trim();

    if (_isSubredditQuery(rawText)) {
      String subredditName = _extractSubredditName(rawText);
      if (subredditName.length < 3) return;
      await _navigateToSubreddit(subredditName);
    } else {
      Get.back();
      Get.find<HomeController>().updateSearchQuery(rawText);
    }
  }

  bool _isSubredditQuery(String text) => text.toLowerCase().startsWith('r/');

  String _extractSubredditName(String text) =>
      text.substring(2).replaceAll(RegExp(r'\s+'), '');

  /// Keeps [isSubredditToggle] reflecting the text field, e.g. if the
  /// user types `r/` themselves the toggle flips on, and if they
  /// backspace it away the toggle flips back off. Skipped while
  /// [toggleSubredditPrefix] is itself editing the text, so the two
  /// don't fight each other / recurse.
  void _syncSubredditToggleFromText() {
    if (_isSyncingSubredditPrefix) return;
    final matchesPrefix = _isSubredditQuery(searchController.text);
    if (isSubredditToggle.value != matchesPrefix) {
      isSubredditToggle.value = matchesPrefix;
    }
  }

  /// Flips the r/ toggle and adds/removes the `r/` prefix on the
  /// search text to match, so the user never has to type it
  /// themselves (though they still can, which flips the toggle on
  /// automatically via [_syncSubredditToggleFromText]).
  void toggleSubredditPrefix() {
    final turningOn = !isSubredditToggle.value;
    isSubredditToggle.value = turningOn;

    final text = searchController.text;
    final hasPrefix = _isSubredditQuery(text);
    if (turningOn == hasPrefix) return;

    final selectionEnd = searchController.selection.end;
    final selectionValid = selectionEnd >= 0 && selectionEnd <= text.length;
    final cursorFromEnd = selectionValid ? text.length - selectionEnd : 0;

    _isSyncingSubredditPrefix = true;
    final newText = turningOn ? 'r/$text' : text.substring(2);
    searchController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: (newText.length - cursorFromEnd).clamp(0, newText.length),
      ),
    );
    _isSyncingSubredditPrefix = false;
  }

  Future<void> _navigateToSubreddit(String subredditName) async {
    isValidating.value = true;
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
          suggestSFW.value ? allSFWSubreddit : allNSFWSubreddit);
      return;
    }
    suggestions.clear();
    List<String> sourceList =
        suggestSFW.value ? allSFWSubreddit : allNSFWSubreddit;

    suggestions.addAll(sourceList
            .where((element) => element
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .take(20) // Limit to 20 suggestions
        );
  }

  void _updateApiSuggestions() {
    if (searchController.text.isEmpty) {
      suggestions.value = List<SubredditModel>.from(apiSubreddits);
      return;
    }

    suggestions.clear();
    suggestions.addAll(apiSubreddits
            .where((subreddit) => subreddit.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .take(20) // Limit to 20 suggestions
        );
  }

  Future<void> _loadLocalSubreddits() async {
    allSFWSubreddit =
        await _loadSubredditFromFile(AssetPaths.data.sfwSubreddit);
    allNSFWSubreddit =
        await _loadSubredditFromFile(AssetPaths.data.nsfwSubreddit);

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
    updateSearchTypes();

    isLoadingApiData.value = true;

    try {
      List<SubredditModel> fetchedSubreddits =
          await SubrankingCacheService.fetchSubredditNames(
        type: selectedType.value,
        category: selectedCategory.value,
        nsfw: selectedCategory.value != SubrankingCategory.sfw,
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
    _navigateToSubreddit(subredditName);
  }

  void toggleSuggestSFW() {
    suggestSFW.value = !suggestSFW.value;

    // if (currentSearchMode.value == SearchMode.api) {
    //   _loadApiSubreddits(); // Reload with new NSFW setting
    // } else {
    // _updateSuggestions();
    // }
    if (currentSearchMode.value == SearchMode.local) {
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
