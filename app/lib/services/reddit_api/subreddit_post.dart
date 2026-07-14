part of 'reddit_api.dart';

/// Reddit sometimes rotates the session cookie via `Set-Cookie` on
/// normal API responses. `package:http`'s `Response.headers` map only
/// exposes the response header `set-cookie` (not `cookie`, which is a
/// *request* header - the previous implementation was checking the
/// wrong key and so rotated cookies were silently dropped, which can
/// eventually lead to the session going stale).
///
/// This does a best-effort merge of `name=value` pairs from
/// `Set-Cookie` into the existing cookie header string, ignoring
/// cookie attributes (Path/Expires/etc.) which we don't need to send
/// back.
String _mergeSetCookie(String existingCookieHeader, String setCookieHeader) {
  final existing = <String, String>{};
  for (final pair in existingCookieHeader.split(';')) {
    final idx = pair.indexOf('=');
    if (idx <= 0) continue;
    existing[pair.substring(0, idx).trim()] = pair.substring(idx + 1).trim();
  }

  // A single `Set-Cookie` header only ever describes ONE cookie
  // (`name=value; Attr=...; Attr2`), so just take the first segment.
  final firstSegment = setCookieHeader.split(';').first;
  final idx = firstSegment.indexOf('=');
  if (idx > 0) {
    final name = firstSegment.substring(0, idx).trim();
    final value = firstSegment.substring(idx + 1).trim();
    if (name.isNotEmpty) existing[name] = value;
  }

  return existing.entries.map((e) => '${e.key}=${e.value}').join('; ');
}

RedditInfoModel _requireRedditInfo() {
  final info = Get.find<AuthController>().redditInfo.value;
  if (info == null) throw Exception('No RedditInfo Found');
  return info;
}

/// Applies any rotated `Set-Cookie` from [response] to persisted auth
/// state, and returns `true` if the response indicated an expired
/// session (401), in which case the caller should stop and bail out.
bool _handleAuthSideEffects(http.Response response, RedditInfoModel info) {
  final setCookie = response.headers['set-cookie'];
  if (setCookie != null && setCookie.isNotEmpty) {
    final merged = _mergeSetCookie(info.cookies ?? '', setCookie);
    Get.find<AuthController>().updateCookie(merged);
  }

  if (response.statusCode == 401) {
    Get.find<AuthController>().handleSessionExpired();
    return true;
  }
  return false;
}

Future<RedditPostResponse?> _fetchSubredditPosts({
  required String subreddit,
  String? before,
  String? after,
  RedditSortType sortType = RedditSortType.best,
  int limit = 25,
  ApiCallListener? listener,
}) async {
  final info = _requireRedditInfo();

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

    http.Response response = await http.get(
      uri,
      headers: {
        'User-Agent': info.ua ?? "",
        'Cookie': info.cookies ?? "",
        "Accept": '*/*'
      },
    );

    if (_handleAuthSideEffects(response, info)) return null;

    if (!ApiCallHandler.handleApiResponse(response, listener: listener)) {
      return null;
    }
    final data = jsonDecode(response.body);
    return RedditPostResponse.fromJson(subreddit: subreddit, json: data);
  } catch (e) {
    debugPrint("fetchSubredditPosts error: $e");
  }
  return null;
}

Future<bool> _checkIfSubredditExist(String subreddit) async {
  bool result = false;
  final info = _requireRedditInfo();

  String url =
      'https://www.reddit.com/r/$subreddit/about/rules.json?raw_json=1';

  try {
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': info.ua ?? "",
        'Cookie': info.cookies ?? "",
        "Accept": '*/*'
      },
    );

    if (_handleAuthSideEffects(response, info)) return false;

    var json = jsonDecode(response.body);
    result = json['rules'] != null;
  } catch (e) {
    debugPrint("checkIfSubredditExist error: $e");
    result = false;
  }
  return result;
}
