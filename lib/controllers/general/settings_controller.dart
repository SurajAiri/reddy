import 'package:get/get.dart';

import '../../config/utils/enums.dart';
import '../../services/subranking/utility.dart';
enum SearchMode {
  local,
  api,
}


class SettingsController extends GetxController {
  RxBool isSafeContentOnly = true.obs;
  RxBool isPremium = false.obs;
  RxBool sound = true.obs;
  RxBool autoPlay = true.obs;
  RxBool isLooping = false.obs;
  RxDouble playbackSpeed = 1.5.obs;
  RxnString focusPostId = RxnString();
  Rx<ImageQuality> imageQuality = ImageQuality.medium.obs;

  SubrankingType selectedSubrankingType = SubrankingType.largest;
  SubrankingCategory selectedSubrankingCategory = SubrankingCategory.sfw;
  SearchMode currentSearchMode = SearchMode.local;

  // void toggleSafeContentOnly() {
  //   isSafeContentOnly.value = !isSafeContentOnly.value;
  //   print('value changed to ${isSafeContentOnly.value}');
  // }

  void lockVideoPlayer(String postId) {
    focusPostId.value = postId;
  }

  void releaseVideoPlayer(String postId) {
    if (postId != focusPostId.value) return;
    focusPostId.value = null;
  }
}
