import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController controller;
  double progress = 0;
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print(progress);
          },
        ),
      )
      ..loadRequest(Uri.parse("www.google.com"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 338,
      width: 600,
      child: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.red.withOpacity(0.9))),
        ],
      ),
    );
  }
}
