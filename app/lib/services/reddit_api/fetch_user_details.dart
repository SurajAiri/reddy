part of 'reddit_api.dart';

/// Simple in-memory cache so we don't re-fetch the same author's
/// profile (avatar, karma, etc.) every time one of their posts scrolls
/// into view, or every time the same subreddit is revisited.
///
/// This intentionally lives only in memory (cleared on app restart) -
/// it doesn't need to be disk-persisted, it just needs to survive for
/// the current session to avoid the N+1 request pattern the feed used
/// to have (one HTTP request per post, per author, on every parse).
final Map<String, RedditUserModel> _userCache = {};
final Map<String, Future<RedditUserModel?>> _inFlightUserFetch = {};

Future<RedditUserModel?> _fetchUserDetails({
  required String username,
  ApiCallListener? listener,
}) async {
  final cached = _userCache[username];
  if (cached != null) return cached;

  // If a request for this username is already in flight (common when
  // several posts by the same author render around the same time),
  // just await that instead of firing a duplicate request.
  final pending = _inFlightUserFetch[username];
  if (pending != null) return pending;

  final future = _fetchUserDetailsUncached(username: username, listener: listener);
  _inFlightUserFetch[username] = future;
  try {
    final result = await future;
    if (result != null) _userCache[username] = result;
    return result;
  } finally {
    _inFlightUserFetch.remove(username);
  }
}

Future<RedditUserModel?> _fetchUserDetailsUncached({
  required String username,
  ApiCallListener? listener,
}) async {
  final info = _requireRedditInfo();
  try {
    Uri url = Uri.parse(
        "${RedditEndpoints.baseUrl}/${RedditEndpoints.userDetails}$username/about.json?raw_json=1");
    http.Response response = await http.get(
      url,
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
    return RedditUserModel.fromJson(data['data']);
  } catch (e) {
    debugPrint("fetchUserDetails error ($username): $e");
  }
  return null;
}
