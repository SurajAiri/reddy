part of 'reddit_api.dart';

Future<RedditUserModel?> _fetchUserDetails({
  required String username,
  ApiCallListener? listener,
}) async {
  final info = Get.find<HomeController>().getRedditInfo;
  if (info == null) throw Exception('No RedditInfo Found');
  try {
    Uri url = Uri.parse(
        "${RedditEndpoints.baseUrl}/${RedditEndpoints.userDetails}/$username/about.json");
    http.Response response = await http.get(
      url,
      headers: {
        'User-Agent': info.ua ?? "",
        'Cookie': info.cookies ?? "",
        "Accept": '*/*'
      },
    );
    if (!ApiCallHandler.handleApiResponse(response, listener: listener)) {
      return null;
    }
    final data = jsonDecode(response.body);
    if (response.headers['Cookie'] != null) {
      Get.find<HomeController>()
          .updateRedditCookie(response.headers['Cookie'] ?? info.cookies ?? "");
    }
    return RedditUserModel.fromJson(data['data']);
  } catch (e) {
    debugPrint("reddit user error: $e");
  }
  return null;
}
