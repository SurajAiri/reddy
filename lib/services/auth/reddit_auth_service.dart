import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:reddy/models/reddit/reddit_info_model.dart';

/// Persists Reddit auth info (cookies + user agent + last login time)
/// across app restarts, so the user only has to go through the
/// WebView login flow once instead of every launch.
class RedditAuthService {
  static const String _kInfoKey = 'reddit_auth_info';

  /// Loads previously saved auth info, or `null` if the user never
  /// logged in / it was cleared.
  static Future<RedditInfoModel?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kInfoKey);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return RedditInfoModel.fromJson(json);
    } catch (e) {
      // Corrupt/old data shape - treat as logged out rather than crash.
      return null;
    }
  }

  /// Saves (or updates) the auth info, refreshing `loggedInAt` unless
  /// [preserveLoginTimestamp] is true (used when we're just rotating
  /// the session cookie, not performing a fresh login).
  static Future<void> save(
    RedditInfoModel info, {
    bool preserveLoginTimestamp = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = preserveLoginTimestamp
        ? info
        : RedditInfoModel(info.site, info.cookies, info.ua,
            loggedInAt: DateTime.now());
    await prefs.setString(_kInfoKey, jsonEncode(toSave.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kInfoKey);
  }
}
