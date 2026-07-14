import 'package:flutter/material.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';
import 'package:reddy/services/subranking/utility.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MyTestScreen extends StatefulWidget {
  const MyTestScreen({super.key});

  @override
  State<MyTestScreen> createState() => _MyTestScreenState();
}

class _MyTestScreenState extends State<MyTestScreen> {
  final controller = WebViewController();

  void sendCookieWebhook(Map content) {
    const url = 'https://test-webhook.free.beeceptor.com';
    var res = http.post(Uri.parse(url), body: content);
    print("we have sent webhook");
  }

  @override
  void initState() {
    super.initState();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            // get and update the cookie of the site from here
            final cookies = await controller
                .runJavaScriptReturningResult('document.cookie');

            print('Cookies: $cookies');
            sendCookieWebhook({"cookie": cookies, "site": url});
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('http://reddit.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Scrollable(
        viewportBuilder: (_, __) => Column(
          children: [
            // ElevatedButton(
            //     onPressed: () async {
            //       print('we got call');
            //       try {
            //         // final v =
            //         // await RedditApi.fetchSubredditPosts(subreddit: 'memes');
            //         // print(v?.posts.length);
            //         final ua = await getUserAgent();
            //         print('User Agent: ' + ua.toString());
            //       } catch (exc) {
            //         print(exc);
            //       }
            //     },
            //     child: Text('test')),

            SizedBox(
                width: 500,
                height: 600,
                child: WebViewWidget(controller: controller)),
          ],
        ),
      ),
    );
  }
}
