import 'dart:convert';
import 'package:reddy/models/subreddits/subreddit_model.dart';
import 'package:reddy/services/subranking/utility.dart';
import 'package:http/http.dart' as http;

// Cache entry model
class CacheEntry {
  final List<SubredditModel> data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

// Cache service for managing subreddit data
class SubrankingCacheService {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration _defaultTtl = Duration(minutes: 10); // Cache for 10 minutes

  // Generate cache key from parameters
  static String _generateCacheKey({
    required SubrankingType type,
    required SubrankingCategory category,
    required bool nsfw,
    required int page,
    required int limit,
    String? query,
    int? filter,
  }) {
    return 'subreddit_${type.toString()}_${category.toString()}_${nsfw}_${page}_${limit}_${query ?? 'null'}_${filter ?? 'null'}';
  }

  // Get data from cache if available and not expired
  static List<SubredditModel>? _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data;
    }
    // Remove expired entry
    if (entry != null && entry.isExpired) {
      _cache.remove(key);
    }
    return null;
  }

  // Store data in cache
  static void _storeInCache(String key, List<SubredditModel> data) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: _defaultTtl,
    );
  }

  // Clear cache manually
  static void clearCache() {
    _cache.clear();
  }

  // Clear expired entries
  static void clearExpiredEntries() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  // Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int validEntries = 0;
    int expiredEntries = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredEntries++;
      } else {
        validEntries++;
      }
    }

    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
    };
  }

  // Main method that users will call - includes caching logic
  static Future<List<SubredditModel>> fetchSubredditNames({
    SubrankingType type = SubrankingType.largest,
    SubrankingCategory category = SubrankingCategory.sfw,
    bool nsfw = false,
    int page = 1,
    int limit = 100,
    String? query,
    int? filter,
  }) async {
    final cacheKey = _generateCacheKey(
      type: type,
      category: category,
      nsfw: nsfw,
      page: page,
      limit: limit,
      query: query,
      filter: filter,
    );

    // Try to get from cache first
    final cachedData = _getFromCache(cacheKey);
    if (cachedData != null) {
      print("Cache hit for key: $cacheKey");
      return cachedData;
    }

    print("Cache miss for key: $cacheKey - fetching from server");

    // If not in cache or expired, fetch from server
    final freshData = await _fetchFromServer(
      type: type,
      category: category,
      nsfw: nsfw,
      page: page,
      limit: limit,
      query: query,
      filter: filter,
    );

    // Store in cache if data was successfully fetched
    if (freshData.isNotEmpty) {
      _storeInCache(cacheKey, freshData);
    }

    return freshData;
  }

  // Internal method for server calls - keeps your original logic intact
  static Future<List<SubredditModel>> _fetchFromServer({
    SubrankingType type = SubrankingType.largest,
    SubrankingCategory category = SubrankingCategory.sfw,
    bool nsfw = false,
    int page = 1,
    int limit = 100,
    String? query,
    int? filter,
  }) async {
    print('Fetching from server with parameters:');
    print('Type: $type, Category: $category, NSFW: $nsfw, Page: $page, Limit: $limit, Query: $query, Filter: $filter');
    const String baseUrl = "https://subranking.com/load_data";
    
    Uri uri = Uri.parse(baseUrl).replace(queryParameters: {
      'type': SubrankingUtility.getSubrankingTypeString(type),
      'category':
          '${SubrankingUtility.getSubrankingCategoryString(category)}-${SubrankingUtility.getSubrankingTypeString(type)}',
      'nsfw': nsfw.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null) 'query': query,
      if (filter != null) 'filter': filter.toString(),
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = response.body;
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
