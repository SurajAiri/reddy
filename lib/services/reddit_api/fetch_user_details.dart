part of 'reddit_api.dart';

Future<RedditUserModel?> _fetchUserDetails({
  required String username,
  ApiCallListener? listener,
}) async {
  try {
    Uri url = Uri.parse(
        "${RedditEndpoints.baseUrl}/${RedditEndpoints.userDetails}/$username/about.json");
    http.Response response = await http.get(url);
    if (!ApiCallHandler.handleApiResponse(response, listener: listener)) {
      return null;
    }
    final data = jsonDecode(response.body);

    return RedditUserModel.fromJson(data['data']);
  } catch (e) {
    debugPrint("error: $e");
  }
  return null;
}
