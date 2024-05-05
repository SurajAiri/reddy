import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meme_life_v2/config/utils/api_callback_handler.dart';
import 'package:meme_life_v2/config/utils/api_callback_listener.dart';
import 'package:meme_life_v2/models/reddit/reddit_post_model.dart';
import 'package:http/http.dart' as http;
import 'package:meme_life_v2/models/reddit/reddit_user_model.dart';

import 'reddit_endpoints.dart';

part 'fetch_memes.dart';
part 'fetch_user_details.dart';

class RedditApi {
  static Future<List<RedditPostModel>> fetchMemes({
    String? subreddit,
  }) async {
    // https: //www.reddit.com/r/memes/new.json?limit=25&raw_json=1
    String url =
        "${RedditEndpoints.baseUrl}/r/$subreddit/new.json?limit=1&raw_json=1";
    return _fetchMemes(url: Uri.parse(url));
  }

  static Future<RedditUserModel?> fetchUserDetails({
    required String username,
    ApiCallListener? listener,
  }) async {
    return _fetchUserDetails(username: username, listener: listener);
  }
}
