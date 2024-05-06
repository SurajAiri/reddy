import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/services/reddit_api/reddit_api.dart';

class RedditSearchController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxBool isValidating = false.obs;
  RxBool isSearching = false.obs;
  FocusNode searchFocusNode = FocusNode();

  RxInt searchTextLength = 0.obs;
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchTextLength.value = searchController.text.length;
    });
    searchFocusNode.requestFocus();
  }

  void validateSearch() async {
    if (searchTextLength.value < 3) return;
    isValidating.value = true;
    bool v = await RedditApi.checkIfSubredditExist(
      searchController.text,
    );
    isValidating.value = false;
    if (v) {
      Get.back();
      Get.find<HomeController>().fetchPosts(subreddit: searchController.text);
    }
  }
}
