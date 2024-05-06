import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reddy/config/utils/api_callback_handler.dart';
import 'package:reddy/config/utils/api_callback_listener.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:http/http.dart' as http;
import 'package:reddy/models/reddit/reddit_post_response.dart';
import 'package:reddy/models/reddit/reddit_user_model.dart';

import 'reddit_endpoints.dart';

part 'subreddit_post.dart';
part 'fetch_user_details.dart';

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

  static Future<bool> checkIfSubredditExist(String subreddit) async {
    return _checkIfSubredditExist(subreddit);
  }

  static Future<RedditUserModel?> fetchUserDetails({
    required String username,
    ApiCallListener? listener,
  }) async {
    return _fetchUserDetails(username: username, listener: listener);
  }
}
