import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reddy/config/utils/enums.dart';

class Utility {
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
}
