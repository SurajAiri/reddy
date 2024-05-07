import 'dart:convert';

import 'package:get/get.dart';
import 'package:reddy/models/reddit/reddit_post_model.dart';

class TestController extends GetxController {
  // RxBool isSafeContentOnly = true.obs;

  // void toggleSafeContentOnly() {
  //   // isSafeContentOnly.value = !isSafeContentOnly.value;
  //   isSafeContentOnly.toggle();
  //   isSafeContentOnly.refresh();
  //   update();
  //   print('value changed to ${isSafeContentOnly.value}');
  // }

  RxList<RedditVideo> videos = RxList();
  @override
  void onInit() {
    dummyData();
    super.onInit();
  }

  void dummyData() {
    var res =
        """{"bitrate_kbps":450,"fallback_url":"https://v.redd.it/c5n7hng4iwyc1/DASH_270.mp4?source=fallback","has_audio":true,"height":256,"width":460,"scrubber_media_url":"https://v.redd.it/c5n7hng4iwyc1/DASH_96.mp4","dash_url":"https://v.redd.it/c5n7hng4iwyc1/DASHPlaylist.mpd?a=1717644642%2CN2EzNDMwOTdhZTBhZGU4MTZjZDFhMzA4NjQ4ZjFjZmU0MGExYmNiNGRjNjQyMDJlYWNmMDgwZjM1MWYzNTJkNQ%3D%3D&v=1&f=sd","duration":20,"hls_url":"https://v.redd.it/c5n7hng4iwyc1/HLSPlaylist.m3u8?a=1717644642%2CMmNkODk2OWJjNTVhOTA3ZmJhMjdjZDY4OTYyMTFhYzFiOTNhMTZlZGQ4NGViMTc4ZjM0MGUwZmM3YjQ1ZGQyZg%3D%3D&v=1&f=sd","is_gif":false,"transcoding_status":"completed"}""";
    videos.value = List.generate(
      6,
      (index) => RedditVideo.fromJson(jsonDecode(res)),
    );
  }

  void floatingActionButtonPressed() {
    print('floatingActionButtonPressed');
    dummyData();
  }
}
