import 'package:get/get.dart';

import '../../config/utils/enums.dart';

class SettingsController extends GetxController {
  RxBool isSafeContentOnly = true.obs;
  RxBool isPremium = true.obs;
  RxBool isMuted = false.obs;
  RxBool autoPlay = true.obs;
  RxBool isLooping = false.obs;
  RxDouble playbackSpeed = 1.5.obs;
  RxnString focusPostId = RxnString();
  Rx<ImageQuality> imageQuality = ImageQuality.medium.obs;

  // void toggleSafeContentOnly() {
  //   isSafeContentOnly.value = !isSafeContentOnly.value;
  //   print('value changed to ${isSafeContentOnly.value}');
  // }
}
