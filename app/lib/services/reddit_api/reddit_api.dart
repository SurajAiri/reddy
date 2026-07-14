import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/api_callback_handler.dart';
import 'package:reddy/config/utils/api_callback_listener.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/auth_controller.dart';
import 'package:reddy/models/reddit/reddit_comment_model.dart';
import 'package:reddy/models/reddit/reddit_info_model.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:http/http.dart' as http;
import 'package:reddy/models/reddit/reddit_post_response.dart';
import 'package:reddy/models/reddit/reddit_user_model.dart';

import 'reddit_endpoints.dart';

part 'subreddit_post.dart';
part 'fetch_user_details.dart';
part 'post_comments.dart';

class RedditApi {
  static Future<RedditPostResponse?> fetchSubredditPosts({
    required String subreddit,
    String? before,
    String? after,
    RedditSortType sortType = RedditSortType.new_,
    int limit = 25,
  }) async {
    return _fetchSubredditPosts(
      subreddit: subreddit,
      before: before,
      after: after,
      sortType: sortType,
      limit: limit,
    );
  }

  static Future<RedditPostResponse?> fetchSearchPosts({
    required String query,
    String? before,
    String? after,
    RedditSortType sortType = RedditSortType.best,
    int limit = 25,
  }) async {
    return _fetchSearchPosts(
      query: query,
      before: before,
      after: after,
      sortType: sortType,
      limit: limit,
    );
  }

  static Future<List<RedditCommentModel>?> fetchPostComments({
    required String permalink,
    CommentSortType sortType = CommentSortType.best,
    int limit = 100,
  }) async {
    return _fetchPostComments(
      permalink: permalink,
      sortType: sortType,
      limit: limit,
    );
  }

  static Future<bool> checkIfSubredditExist(String subreddit) async {
    return _checkIfSubredditExist(subreddit);
  }

  static Future<RedditUserModel?> fetchUserDetails({
    required String username,
    ApiCallListener? listener,
  }) async {
    return _fetchUserDetails(username: username, listener: listener);
  }

  /// Clears the in-memory user-details cache. Handy for tests / logout.
  static void clearUserCache() => _userCache.clear();
}
