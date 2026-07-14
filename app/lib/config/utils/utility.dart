import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reddy/config/utils/enums.dart';

class Utility {
  /// Reddit-style compact vote/comment counts: 950, 1.2k, 34k, 1.1m.
  /// `NumberFormat.compact()` alone gives "1.2K" (capital K, and no
  /// special-casing below 1000) - lowercased here to match Reddit's
  /// own formatting instead of introducing an inconsistent style.
  static String compactNumber(int value) {
    if (value.abs() < 1000) return value.toString();
    return NumberFormat.compact().format(value).toLowerCase();
  }

  static String encodeDate(DateTime? value) {
    if (value == null) return "DD / MM / YYYY";
    return DateFormat('dd / MM / yyyy').format(value);
  }

  static String encodeDateApi(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  static String encodeTime(TimeOfDay? value) {
    if (value == null) return "HH:MM A";
    var d = DateTime(2000, 1, 1, value.hour, value.minute);
    return DateFormat('hh : mm a').format(d);
  }

  static String redditSelfTextHtmlIssueFix(String jsonString) {
    // Find the index of "selftext_html" and "likes" keys
    int startIndex = jsonString.indexOf('"selftext_html"');
    int endIndex = jsonString.indexOf('"likes"', startIndex);

    // Remove the substring between "selftext_html" and "likes" keys
    return jsonString.replaceRange(startIndex, endIndex, '');
  }

  static String encodeRedditSortType(RedditSortType sort) {
    return sort.toString().split('.').last.replaceAll("_", "");
  }

  /// Reddit only exposes a `best` listing on the aggregated home/all
  /// feed, not on individual subreddits (`/r/<sub>/best.json` 404s),
  /// so when browsing a specific subreddit we fall back to `hot`,
  /// which is the closest equivalent.
  static String encodeRedditSortTypeForSubreddit(RedditSortType sort) {
    if (sort == RedditSortType.best) {
      return encodeRedditSortType(RedditSortType.hot);
    }
    return encodeRedditSortType(sort);
  }

  /// Reddit's search endpoint (`/search.json`) only accepts
  /// `relevance | hot | top | new | comments` for its `sort` param -
  /// it has no `best` or `rising` option - so map those onto the
  /// closest equivalent instead of sending an invalid value.
  static String encodeRedditSortTypeForSearch(RedditSortType sort) {
    switch (sort) {
      case RedditSortType.best:
        return 'relevance';
      case RedditSortType.rising:
        return encodeRedditSortType(RedditSortType.new_);
      default:
        return encodeRedditSortType(sort);
    }
  }

  static String sortTypeDisplayName(RedditSortType sort) {
    switch (sort) {
      case RedditSortType.best:
        return 'Best';
      case RedditSortType.hot:
        return 'Hot';
      case RedditSortType.new_:
        return 'New';
      case RedditSortType.top:
        return 'Top';
      case RedditSortType.rising:
        return 'Rising';
      case RedditSortType.controversial:
        return 'Controversial';
    }
  }

  static IconData sortTypeIcon(RedditSortType sort) {
    switch (sort) {
      case RedditSortType.best:
        return Icons.auto_awesome;
      case RedditSortType.hot:
        return Icons.local_fire_department;
      case RedditSortType.new_:
        return Icons.fiber_new;
      case RedditSortType.top:
        return Icons.trending_up;
      case RedditSortType.rising:
        return Icons.rocket_launch;
      case RedditSortType.controversial:
        return Icons.bolt;
    }
  }

  static String encodeImageQuality(ImageQuality quality) {
    return switch (quality) {
      ImageQuality.lowest => "Lowest",
      ImageQuality.low => "Low",
      ImageQuality.mediumLow => "Medium Low",
      ImageQuality.medium => "Medium",
      ImageQuality.mediumHigh => "Medium High",
      ImageQuality.high => "High",
      ImageQuality.highest => "Highest",
    };
  }

  /// Reddit's comment sort query param uses `confidence` for what the
  /// UI calls "best" - everything else matches the enum name.
  static String encodeCommentSortType(CommentSortType sort) {
    if (sort == CommentSortType.best) return 'confidence';
    return sort.toString().split('.').last.replaceAll('_', '');
  }

  static String commentSortTypeDisplayName(CommentSortType sort) {
    switch (sort) {
      case CommentSortType.best:
        return 'Best';
      case CommentSortType.top:
        return 'Top';
      case CommentSortType.new_:
        return 'New';
      case CommentSortType.controversial:
        return 'Controversial';
      case CommentSortType.old:
        return 'Old';
      case CommentSortType.qa:
        return 'Q&A';
    }
  }

  static String encodePostContentType(PostContentType type) {
    return switch (type) {
      PostContentType.image => "Image",
      PostContentType.gif => "Gif",
      PostContentType.gifv => "Gifv",
      PostContentType.video => "Video",
      PostContentType.text => "Text",
    };
  }
}
