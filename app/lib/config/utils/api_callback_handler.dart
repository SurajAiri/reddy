import 'dart:convert';

import 'api_callback_listener.dart';
import 'package:http/http.dart' as http;
import 'ui_utility.dart';

class ApiCallHandler {
  /// error handled and returns whether success or not
  /// `true` success
  /// `false` failure
  static bool handleApiResponse(
    http.Response response, {
    ApiCallListener? listener,
  }) {
    bool res = false;
    var json = jsonDecode(response.body);
    if (response.statusCode < 400) {
      // success
      _call(listener);
      res = true;
    } else if (response.statusCode == 401) {
      // login token expire
      _call(listener, error: "Token expired");
    } else {
      _call(listener, error: json['message']);
    }
    return res;
  }

  static void _call(ApiCallListener? listener, {String? error}) {
    if (error == null) {
      listener?.onSuccess?.call();
    } else {
      listener?.onError?.call(error);
      UiUtility.showToast(error, isError: true);
      print("error: $error");
    }
    listener?.onCompleted?.call();
  }
}
