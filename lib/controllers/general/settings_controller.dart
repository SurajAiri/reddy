import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/utils/enums.dart';
import '../../services/subranking/utility.dart';

enum SearchMode {
  local,
  api,
}

class SettingsController extends GetxController {
  static const _kSafeContentOnly = 'settings_safe_content_only';
  static const _kSound = 'settings_sound';
  static const _kAutoPlay = 'settings_autoplay';
  static const _kIsLooping = 'settings_is_looping';
  static const _kPlaybackSpeed = 'settings_playback_speed';
  static const _kImageQuality = 'settings_image_quality';
  static const _kIsPremium = 'settings_is_premium';

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

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadPersistedSettings();
    // Persist automatically whenever any of these settings changes.
    ever(isSafeContentOnly, (_) => _persistSettings());
    ever(sound, (_) => _persistSettings());
    ever(autoPlay, (_) => _persistSettings());
    ever(isLooping, (_) => _persistSettings());
    ever(playbackSpeed, (_) => _persistSettings());
    ever(imageQuality, (_) => _persistSettings());
    ever(isPremium, (_) => _persistSettings());
  }

  Future<void> _loadPersistedSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;
    isSafeContentOnly.value = prefs.getBool(_kSafeContentOnly) ?? true;
    sound.value = prefs.getBool(_kSound) ?? true;
    autoPlay.value = prefs.getBool(_kAutoPlay) ?? true;
    isLooping.value = prefs.getBool(_kIsLooping) ?? false;
    playbackSpeed.value = prefs.getDouble(_kPlaybackSpeed) ?? 1.5;
    isPremium.value = prefs.getBool(_kIsPremium) ?? false;
    final savedQualityIndex = prefs.getInt(_kImageQuality);
    if (savedQualityIndex != null &&
        savedQualityIndex >= 0 &&
        savedQualityIndex < ImageQuality.values.length) {
      imageQuality.value = ImageQuality.values[savedQualityIndex];
    }
  }

  Future<void> _persistSettings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_kSafeContentOnly, isSafeContentOnly.value);
    await prefs.setBool(_kSound, sound.value);
    await prefs.setBool(_kAutoPlay, autoPlay.value);
    await prefs.setBool(_kIsLooping, isLooping.value);
    await prefs.setDouble(_kPlaybackSpeed, playbackSpeed.value);
    await prefs.setInt(_kImageQuality, imageQuality.value.index);
    await prefs.setBool(_kIsPremium, isPremium.value);
  }

  void lockVideoPlayer(String postId) {
    focusPostId.value = postId;
  }

  void releaseVideoPlayer(String postId) {
    if (postId != focusPostId.value) return;
    focusPostId.value = null;
  }
}
