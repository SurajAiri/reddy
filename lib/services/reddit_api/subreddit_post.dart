part of 'reddit_api.dart';

Future<RedditPostResponse?> _fetchSubredditPosts({
  required String subreddit,
  String? before,
  String? after,
  RedditSortType sortType = RedditSortType.best,
  int limit = 25,
  ApiCallListener? listener,
}) async {
  final info = Get.find<HomeController>().getRedditInfo;
  if (info == null) throw Exception('No RedditInfo Found');

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

    http.Response response = await http.get(
      uri,
      headers: {
        'User-Agent': info.ua ?? "",
        'Cookie': info.cookies ?? "",
        "Accept": '*/*'
      },
    );
    print(response.statusCode);
    print(response.headers['content-type']);
    print(response.request?.url);
    print(response.body);
    if (!ApiCallHandler.handleApiResponse(response, listener: listener)) {
      return null;
    }
    final data = jsonDecode(response.body);
    if (response.headers['Cookie'] != null) {
      Get.find<HomeController>()
          .updateRedditCookie(response.headers['Cookie'] ?? info.cookies ?? "");
    }
    return RedditPostResponse.fromJson(subreddit: subreddit, json: data);
  } catch (e) {
    debugPrint("error: $e");
  }
  return null;
}

Future<bool> _checkIfSubredditExist(String subreddit) async {
  bool result = false;
  final info = Get.find<HomeController>().getRedditInfo;
  print('api cookies: ${info?.cookies ?? ""}');
  if (info == null) throw Exception('No RedditInfo Found');

  String url =
      'https://www.reddit.com/r/$subreddit/about/rules.json?raw_json=1';

  print("validation url: $url");
  try {
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': info.ua ?? "",
        'Cookie': info.cookies ?? "",
        "Accept": '*/*'
      },
    );
    print("body: " + response.body);
    var json = jsonDecode(response.body);
    if (json['rules'] != null) {
      result = true;
    } else {
      result = false;
    }
    if (response.headers['Cookie'] != null) {
      Get.find<HomeController>()
          .updateRedditCookie(response.headers['Cookie'] ?? info.cookies ?? "");
    }
  } catch (e) {
    debugPrint("Subreddit error: $e");
    result = false;
  }
  return result;
}
