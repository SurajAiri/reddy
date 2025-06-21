import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reddy/models/subreddits/subreddit_model.dart';
import 'package:reddy/services/subranking/utility.dart';

class SubredditCacheService {
  static const String _cachePrefix = 'subreddit_cache_';
  static const Duration _cacheExpiry = Duration(hours: 24);

  static String _generateCacheKey({
    required SubrankingType type,
    required SubrankingCategory category,
    required bool nsfw,
  }) {
    return '${_cachePrefix}${type.name}_${category.name}_$nsfw';
  }

  static Future<List<SubredditModel>?> getCachedSubreddits({
    required SubrankingType type,
    required SubrankingCategory category,
    required bool nsfw,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(type: type, category: category, nsfw: nsfw);
      
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return null;

      final Map<String, dynamic> cacheMap = jsonDecode(cachedData);
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheMap['cached_at']);
      
      // Check if cache is expired
      if (DateTime.now().difference(cachedAt) > _cacheExpiry) {
        await _removeCachedData(cacheKey);
        return null;
      }

      final List<dynamic> subredditsJson = cacheMap['data'];
      return subredditsJson
          .map((json) => SubredditModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error reading cache: $e');
      return null;
    }
  }

  static Future<void> cacheSubreddits({
    required List<SubredditModel> subreddits,
    required SubrankingType type,
    required SubrankingCategory category,
    required bool nsfw,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(type: type, category: category, nsfw: nsfw);
      
      final cacheData = {
        'cached_at': DateTime.now().millisecondsSinceEpoch,
        'data': subreddits.map((s) => s.toJson()).toList(),
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));
      print('Cached ${subreddits.length} subreddits with key: $cacheKey');
    } catch (e) {
      print('Error caching subreddits: $e');
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys()
          .where((key) => key.startsWith(_cachePrefix))
          .toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      print('Cleared ${keys.length} cache entries');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  static Future<void> _removeCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Error removing cached data: $e');
    }
  }

  static Future<Map<String, DateTime>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheInfo = <String, DateTime>{};
      
      final keys = prefs.getKeys()
          .where((key) => key.startsWith(_cachePrefix))
          .toList();
      
      for (final key in keys) {
        final cachedData = prefs.getString(key);
        if (cachedData != null) {
          final Map<String, dynamic> cacheMap = jsonDecode(cachedData);
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheMap['cached_at']);
          cacheInfo[key.replaceFirst(_cachePrefix, '')] = cachedAt;
        }
      }
      
      return cacheInfo;
    } catch (e) {
      print('Error getting cache info: $e');
      return {};
    }
  }
}