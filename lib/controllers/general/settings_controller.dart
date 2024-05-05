import 'package:get/get.dart';

import '../../config/utils/enums.dart';

class SettingsController extends GetxController {
  RxBool isSafeContentOnly = true.obs;
  Rx<ImageQuality> imageQuality = ImageQuality.lowest.obs;

  void toggleSafeContentOnly() {
    isSafeContentOnly.value = !isSafeContentOnly.value;
    print('value changed to ${isSafeContentOnly.value}');
  }
}
