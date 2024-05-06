import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';
import 'package:reddy/views/features/general/widgets/post_field.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<RedditPostModel> posts = [];
  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    // Fetch posts
    posts = await RedditApi.fetchMemes(
      subreddit: 'failgags',
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reddy'),
        actions: [
          IconButton(
            onPressed: () {
              fetchPosts();
            },
            icon: Icon(Icons.replay_outlined),
          ),
          GetBuilder<SettingsController>(
            builder: (cont) => IconButton(
              onPressed: () {
                cont.toggleSafeContentOnly();
              },
              icon: Icon(cont.isSafeContentOnly.value
                  ? Icons.no_accounts
                  : Icons.safety_check),
            ),
          ),
        ],
      ),
      body: GetBuilder<SettingsController>(
        builder: (controller) => ListView.builder(
          itemBuilder: (context, index) => PostField(
            post: posts[index],
            safeContentOnly:
                Get.find<SettingsController>().isSafeContentOnly.value,
          ),
          itemCount: posts.length,
        ),
      ),
      // body: Center(
      //   child: Image.network(
      //     "https://preview.redd.it/s99mfw2p0rtc1.png?width=108&crop=smart&auto=webp&s=8afd1275d16556d50e6cb7d9df905ead498424fa",
      //     width: double.maxFinite,
      // ),
      // ),
    );
  }
}
