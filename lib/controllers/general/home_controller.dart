import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_response.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

import '../../models/reddit/reddit_post_model.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final settings = Get.find<SettingsController>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isLoading = false.obs;

  Rx<ImageQuality> get imageQuality => settings.imageQuality;
  Rx<bool> get isSafeContentOnly => settings.isSafeContentOnly;

  Rxn<RedditPostResponse> posts =
      Rxn<RedditPostResponse>(RedditPostResponse(subreddit: "memes"));
  RxInt get postCount => (posts.value == null
          ? 0
          : posts.value!.after == null
              ? posts.value!.posts.length
              : posts.value!.posts.length + 1)
      .obs;

  final postScrollController = ScrollController();
  final quickOptionScrollController = ScrollController();

// quick button
  RxList<String> quickOptions = [
    'memes',
    'dankmemes',
    'funny',
    'aww',
    'gaming',
    'pics',
    'videos',
    'news',
    'politics',
    'worldnews',
    'todayilearned',
    'askreddit',
    'science',
    'gifs',
    'movies',
    'mildlyinteresting',
    'tifu',
    'jokes',
  ].obs;

  @override
  void onInit() {
    _fetchPosts(subreddit: posts.value?.subreddit ?? 'memes');
    super.onInit();
  }

  void updateSubreddit(String newSubreddit) {
    if (newSubreddit == posts.value?.subreddit) return;
    _quickOptionPressed(newSubreddit);
    posts.value?.subreddit = newSubreddit;
    _fetchPosts(subreddit: newSubreddit);
  }

  void nextPage() {
    if (posts.value?.after != null) {
      _fetchPosts(subreddit: posts.value?.subreddit ?? "memes", direction: 1);
    }
  }

  void tempFilter() {
    // allow only gifs
    posts.value?.posts
        .removeWhere((post) => post.contentType != PostContentType.video);
    // print(posts.length);
  }

  /// `direction` -1 for previous, 1 for next, 0 for reload
  void _fetchPosts({
    required String subreddit,
    int direction = 0,
  }) async {
    isLoading.value = true;
    // Fetch posts
    posts.value = await RedditApi.fetchSubredditPosts(
      subreddit: posts.value?.subreddit ?? 'memes',
      after: direction == 1 ? posts.value?.after : null,
      before: direction == -1 ? posts.value?.before : null,
      sortType: RedditSortType.new_,
    );
    // tempFilter();
    print("total Post length: ${posts.value?.posts.length}");
    isLoading.value = false;
  }

  void postLinkClicked(String url) {
    var sr = _parseSubredditName(url);
    if (sr.isNotEmpty) {
      updateSubreddit(sr);
    }
  }

  String _parseSubredditName(String url) {
    // Regular expression pattern to match the subreddit name part in the URL
    RegExp regex = RegExp(r"https?://(?:www\.)?reddit\.com/r/([A-Za-z0-9_]+)");
    Match? match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    } else {
      return ""; // or null, depending on how you handle invalid URLs
    }
  }

  void floatingButtonAction() async {
    updateSubreddit('memes');
    settings.isSafeContentOnly.value = true;
  }

  // quick option pressed
  void _quickOptionPressed(String subreddit) {
    if (subreddit == posts.value?.subreddit) return;
    // remove the subreddit from the list and insert it at the top if exists if there are more than 10 pop last one and insert at the top
    print("new subreddit $subreddit");
    if (quickOptions.contains(subreddit)) {
      quickOptions.remove(subreddit);
    } else if (quickOptions.length >= 10) {
      quickOptions.removeLast();
    }
    quickOptions.insert(0, subreddit);
    quickOptionScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
    );
    print("quick options: $quickOptions");
  }
}
