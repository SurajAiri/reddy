import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meme_life_v2/config/utils/enums.dart';
import 'package:meme_life_v2/controllers/general/settings_controller.dart';
import 'package:meme_life_v2/services/reddit_api/reddit_api.dart';

import '../../models/reddit/reddit_post_model.dart';

class HomeController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isLoading = false.obs;
  final settings = Get.find<SettingsController>();
  RxList<RedditPostModel> posts = RxList();
  Rx<ImageQuality> get imageQuality => settings.imageQuality;
  Rx<bool> get isSafeContentOnly => settings.isSafeContentOnly;

  @override
  void onInit() {
    fetchPosts();
    super.onInit();
  }

  void fetchPosts() async {
    isLoading.value = true;
    // Fetch posts
    posts.value = await RedditApi.fetchMemes(
      subreddit: 'memes',
    );
    isLoading.value = false;
  }
}
