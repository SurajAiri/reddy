import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/link_handler.dart';
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

  /// Whether the feed is currently a site-wide reddit search (`query`)
  /// instead of a specific subreddit's listing.
  RxBool isSearchMode = false.obs;
  RxString currentQuery = ''.obs;

  /// Sort applied to whichever feed is active (subreddit or search).
  Rx<RedditSortType> currentSort = RedditSortType.new_.obs;

  /// What the app bar / empty-state should show for the active feed.
  String get feedTitle =>
      isSearchMode.value ? '"${currentQuery.value}"' : 'r/${currentSubreddit.value}';

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
    _fetchPosts(reset: true);
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
    // Skip the no-op guard while in search mode - we still need to
    // switch back to the subreddit feed even if it happens to match
    // the subreddit we were on before the search.
    if (!isSearchMode.value && newSubreddit == currentSubreddit.value) return;
    isSearchMode.value = false;
    _quickOptionPressed(newSubreddit);
    currentSubreddit.value = newSubreddit;
    _fetchPosts(reset: true);
  }

  /// Runs a site-wide reddit search (as opposed to browsing a single
  /// subreddit) for [query] and loads it as the active feed.
  void updateSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    isSearchMode.value = true;
    currentQuery.value = trimmed;
    _fetchPosts(reset: true);
  }

  /// Re-fetches the active feed (subreddit or search) with a new sort.
  void changeSort(RedditSortType sort) {
    if (sort == currentSort.value) return;
    currentSort.value = sort;
    _fetchPosts(reset: true);
  }

  void nextPage() {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    _fetchPosts(reset: false);
  }

  /// Pull-to-refresh: reloads the active feed from the top.
  Future<void> refresh() async {
    await _fetchPosts(reset: true);
  }

  void tempFilter() {
    // allow only gifs
    posts.removeWhere((post) => post.contentType != PostContentType.video);
  }

  Future<void> _fetchPosts({
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
      final response = isSearchMode.value
          ? await RedditApi.fetchSearchPosts(
              query: currentQuery.value,
              after: _after,
              sortType: currentSort.value,
            )
          : await RedditApi.fetchSubredditPosts(
              subreddit: currentSubreddit.value,
              after: _after,
              sortType: currentSort.value,
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

  /// Previously this only handled reddit-internal links (subreddit
  /// switch) and silently did nothing for anything else - tapping a
  /// link post's URL button for a non-reddit link was a dead button.
  /// LinkHandler now covers both cases.
  void postLinkClicked(String url) {
    LinkHandler.open(url);
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
