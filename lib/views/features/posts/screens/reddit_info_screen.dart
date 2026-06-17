import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/models/reddit/reddit_info_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RedditInfoScreen extends StatefulWidget {
  const RedditInfoScreen({super.key});

  @override
  State<RedditInfoScreen> createState() => _RedditInfoScreenState();
}

class _RedditInfoScreenState extends State<RedditInfoScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // Extract the cookies
            final cookies = await controller
                .runJavaScriptReturningResult('document.cookie') as String?;

            print('Cookies: $cookies');
            final ua = await controller.getUserAgent();

            // Check if cookies were successfully extracted
            if (cookies != null && cookies.isNotEmpty) {
              print("Extraction complete, setting values...");
              final info = RedditInfoModel(Uri.parse(url), cookies, ua);

              // Save to data manager
              Get.find<HomeController>().updateRedditInfo(info);

              // Redirect to Home Screen and remove this loading screen from the stack
              Get.back();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://reddit.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Visible Loading UI
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  "Authenticating...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. The Hidden WebView
          // Offstage keeps the WebView active in the tree but completely invisible.
          Offstage(
            offstage: true,
            child: SizedBox(
              width: 1,
              height: 1,
              child: WebViewWidget(controller: controller),
            ),
          ),
          // SizedBox(
          //   width: 500,
          //   height: 800,
          //   child: WebViewWidget(controller: controller),
          // )
        ],
      ),
    );
  }
}
