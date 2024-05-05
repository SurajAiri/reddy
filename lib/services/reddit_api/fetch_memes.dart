part of 'reddit_api.dart';

Future<List<RedditPostModel>> _fetchMemes({
  required Uri url,
  ApiCallListener? listener,
}) async {
  try {
    http.Response response = await http.get(url);
    if (!ApiCallHandler.handleApiResponse(response, listener: listener)) {
      return [];
    }
    final List<RedditPostModel> res = [];
    final data = jsonDecode(response.body);
    data['data']['children'].forEach((v) {
      res.add(RedditPostModel.fromJson(v['data']));
    });
    return res;
  } catch (e) {
    print("error: $e");
  }
  return [];
}
