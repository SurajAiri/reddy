import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static String encodeImageSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes bytes';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(2)} GB';
    }
  }

  String redditSelfTextHtmlIssueFix(String jsonString) {
    // Find the index of "selftext_html" and "likes" keys
    int startIndex = jsonString.indexOf('"selftext_html"');
    int endIndex = jsonString.indexOf('"likes"', startIndex);

    // Remove the substring between "selftext_html" and "likes" keys
    return jsonString.replaceRange(startIndex, endIndex, '');
  }
}
