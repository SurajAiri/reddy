part of 'reddit_api.dart';

Future<RedditPostResponse?> _fetchSubredditPosts({
  required String subreddit,
  String? before,
  String? after,
  RedditSortType sortType = RedditSortType.best,
  int limit = 25,
  ApiCallListener? listener,
}) async {
  try {
    var params = {
      'limit': '$limit',
      'raw_json': '1',
    };
    if (after != null) {
      params['after'] = after;
    } else if (before != null) {
      params['before'] = before;
    }

    Uri uri = Uri.https(
      'www.reddit.com',
      '/r/$subreddit/${Utility.encodeRedditSortType(sortType)}.json',
      params,
    );
    print(uri);

    http.Response response = await http.get(uri);
    if (!ApiCallHandler.handleApiResponse(response, listener: listener)) {
      return null;
    }
    final data = jsonDecode(response.body);
    return RedditPostResponse.fromJson(subreddit: subreddit, json: data);
  } catch (e) {
    debugPrint("error: $e");
  }
  return null;
}

Future<bool> _checkIfSubredditExist(String subreddit) async {
  bool result = false;

  String url =
      'https://www.reddit.com/r/$subreddit/about/rules.json?raw_json=1';

  print("validation url: $url");
  try {
    http.Response response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);
    if (json['site_rules'] != null) {
      result = true;
    } else {
      result = false;
    }
  } catch (e) {
    debugPrint("Subreddit error: $e");
    result = false;
  }
  return result;
}
