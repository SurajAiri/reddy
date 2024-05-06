import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_response.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

import '../../models/reddit/reddit_post_model.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isLoading = false.obs;
  final settings = Get.find<SettingsController>();
  Rx<ImageQuality> get imageQuality => settings.imageQuality;
  Rx<bool> get isSafeContentOnly => settings.isSafeContentOnly;
  // RxList<RedditPostModel> posts = RxList();
  Rxn<RedditPostResponse> posts = Rxn<RedditPostResponse>();

  String? before;
  String? after;

  @override
  void onInit() {
    fetchPosts();
    super.onInit();
  }

  void updateSubreddit(String newSubreddit) {
    if (newSubreddit == posts.value?.subreddit) return;
    posts.value?.subreddit = newSubreddit;
    fetchPosts();
  }

  void nextPage() {
    if (posts.value?.after != null) {
      fetchPosts();
    }
  }

  void tempFilter() {
    // allow only gifs
    posts.value?.posts
        .removeWhere((post) => post.contentType != PostContentType.video);
    // print(posts.length);
  }

  void fetchPosts({String? subreddit}) async {
    if (subreddit != posts.value?.subreddit && subreddit != null) {
      posts.value = RedditPostResponse(subreddit: subreddit);
    }

    isLoading.value = true;
    // Fetch posts
    posts.value = await RedditApi.fetchSubredditPosts(
      subreddit: posts.value?.subreddit ?? 'memes',
      after: posts.value?.after,
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
    // print('Floating button pressed');
    // updateSubreddit('memes');
    // settings.isSafeContentOnly.value = false;
    // updateSubreddit('funny');
    // nextPage();
    settings.imageQuality.value = ImageQuality.mediumHigh;
  }
}
