part of 'reddit_api.dart';

/// Fetches the comment tree for a single post. Reddit's
/// `/r/<sub>/comments/<id>.json` returns a 2-element JSON array:
/// `[postListing, commentsListing]`. We already have the post (it's
/// what got us here), so only the second element is used.
Future<List<RedditCommentModel>?> _fetchPostComments({
  required String permalink,
  CommentSortType sortType = CommentSortType.best,
  int limit = 100,
  ApiCallListener? listener,
}) async {
  final info = _requireRedditInfo();

  try {
    // permalink already looks like "/r/<sub>/comments/<id>/<slug>/" -
    // reddit is happy to have ".json" appended straight after that
    // trailing slash, no reconstruction needed.
    final path = '$permalink.json'.replaceAll('//', '/');

    Uri uri = Uri.https(
      'www.reddit.com',
      path,
      {
        'sort': Utility.encodeCommentSortType(sortType),
        'limit': '$limit',
        'raw_json': '1',
      },
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
    if (data is! List || data.length < 2) return [];

    return RedditCommentModel.listFromCommentsListing(
      data[1] as Map<String, dynamic>,
    );
  } catch (e) {
    debugPrint("fetchPostComments error: $e");
  }
  return null;
}
