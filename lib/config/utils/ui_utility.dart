import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meme_life_v2/config/utils/constants.dart';

class UiUtility {
  static void showToast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.white,
      textColor: isError ? Colors.white : kLabelColor,
      fontSize: 16.0,
    );
  }

  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? initialDate,
  }) {
    return showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
    );
  }

  static Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context,
    TimeOfDay initialTime,
  ) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  static Future<DateTimeRange?> showDateRangePickerDialog({
    required BuildContext context,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTimeRange? initialDateRange,
  }) {
    return showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  // static Future<FilePickerResult?> pickFile({bool withData = false}) async {
  //   return await FilePicker.platform.pickFiles(
  //     withData: withData,
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'pdf', 'doc'],
  //   );
  // }
}
