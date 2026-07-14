import 'dart:convert';

import 'package:reddy/models/subreddits/subreddit_model.dart';
import 'package:reddy/services/subranking/utility.dart';
import 'package:http/http.dart' as http;
class SubrankingApi {
  // fetch subreddit names from subranking API
  /* baseurl: https://subranking.com/load_data
  query parameters:
  type=(largest, weekly, random)
category=(sfw, nsfw, non_verify, karma_friendly)-<type>
nsfw=true/false
Others: page, limit, query (only for random), filter -> returns subreddit less then given subs
  */
  static const String _baseUrl = "https://subranking.com/load_data";

  static Future<List<SubredditModel>> fetchSubredditNames(
      {SubrankingType type = SubrankingType.largest,
      SubrankingCategory category = SubrankingCategory.sfw,
      bool nsfw = false,
      int page = 1,
      int limit = 100,
      String? query,
      int? filter}) async {
    Uri uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'type': SubrankingUtility.getSubrankingTypeString(type),
      'category':
          '${SubrankingUtility.getSubrankingCategoryString(category)}-${SubrankingUtility.getSubrankingTypeString(type)}',
      'nsfw': nsfw.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null) 'query': query,
      if (filter != null) 'filter': filter.toString(),
    });

    try{
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = response.body;
        // print(data);
        // Parse the JSON response
        final json = jsonDecode(data);
        if (json is List) {
          // Convert the JSON list to a list of SubredditModel
          return json.map((item) => SubredditModel.fromJson(item)).toList();
        } else {
          print("Unexpected JSON format: $json");
          return [];
        }
      }

    } catch (e) {
      print("Error fetching subreddits: $e");
    }
      return [];
  }
}
