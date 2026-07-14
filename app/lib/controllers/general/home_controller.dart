import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/controllers/general/auth_controller.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

import '../../models/reddit/reddit_post_model.dart';

class HomeController extends GetxController {
  final settings = Get.find<SettingsController>();
  final auth = Get.find<AuthController>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Spinner for the very first load of a subreddit (or a pull-to-refresh).
  RxBool isLoading = false.obs;

  /// Spinner shown at the bottom of the feed while fetching the next page.
  RxBool isLoadingMore = false.obs;

  /// Whether there's a next page left to fetch (`after` token from Reddit).
  RxBool hasMore = true.obs;

  Rx<ImageQuality> get imageQuality => settings.imageQuality;
  Rx<bool> get isSafeContentOnly => settings.isSafeContentOnly;

  RxString currentSubreddit = 'memes'.obs;

  /// The actual, growing list of posts backing the feed. Unlike the
  /// previous implementation - which replaced this list wholesale on
  /// every "next page" fetch (so scrolling further actually *lost*
  /// the posts you'd already loaded) - pages are now appended here,
  /// which is what makes real infinite scroll possible.
  RxList<RedditPostModel> posts = <RedditPostModel>[].obs;

  final Set<String> _seenPostIds = {};
  String? _after;

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
    super.onInit();
    postScrollController.addListener(_onScroll);
    if (!auth.isLoggedIn) return;
    _fetchPosts(subreddit: currentSubreddit.value, reset: true);
  }

  @override
  void onClose() {
    postScrollController.removeListener(_onScroll);
    postScrollController.dispose();
    quickOptionScrollController.dispose();
    super.onClose();
  }

  /// Auto-loads the next page once the user scrolls near the bottom -
  /// this is the actual infinite-scroll behaviour; there used to be no
  /// scroll listener at all, only a manual "Load more" button, and
  /// even that replaced the list instead of appending to it.
  void _onScroll() {
    if (!postScrollController.hasClients) return;
    final position = postScrollController.position;
    const threshold = 800.0;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      nextPage();
    }
  }

  void updateSubreddit(String newSubreddit) {
    if (newSubreddit == currentSubreddit.value) return;
    _quickOptionPressed(newSubreddit);
    currentSubreddit.value = newSubreddit;
    _fetchPosts(subreddit: newSubreddit, reset: true);
  }

  void nextPage() {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    _fetchPosts(subreddit: currentSubreddit.value, reset: false);
  }

  /// Pull-to-refresh: reloads the current subreddit from the top.
  Future<void> refresh() async {
    await _fetchPosts(subreddit: currentSubreddit.value, reset: true);
  }

  void tempFilter() {
    // allow only gifs
    posts.removeWhere((post) => post.contentType != PostContentType.video);
  }

  Future<void> _fetchPosts({
    required String subreddit,
    required bool reset,
  }) async {
    if (reset) {
      isLoading.value = true;
      _after = null;
      hasMore.value = true;
      _seenPostIds.clear();
      posts.clear();
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await RedditApi.fetchSubredditPosts(
        subreddit: subreddit,
        after: _after,
        sortType: RedditSortType.new_,
      );

      if (response == null) {
        // Either a network hiccup or session expiry (handled by
        // AuthController itself, which will already have redirected
        // to the login screen in that case).
        return;
      }

      // Reddit's `after` cursor can occasionally hand back a post we
      // already have (e.g. right after new posts land), so de-dupe by
      // id instead of blindly appending - avoids duplicate widgets /
      // duplicate GlobalKeys further down the tree.
      final freshPosts = response.posts
          .where((p) => _seenPostIds.add(p.id))
          .toList(growable: false);

      posts.addAll(freshPosts);
      _after = response.after;
      hasMore.value = response.after != null && response.posts.isNotEmpty;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
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
    if (subreddit == currentSubreddit.value) return;
    // remove the subreddit from the list and insert it at the top if exists
    // if there are more than 10 pop last one and insert at the top
    if (quickOptions.contains(subreddit)) {
      quickOptions.remove(subreddit);
    } else if (quickOptions.length >= 10) {
      quickOptions.removeLast();
    }
    quickOptions.insert(0, subreddit);
    if (quickOptionScrollController.hasClients) {
      quickOptionScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceInOut,
      );
    }
  }
}
