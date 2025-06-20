// import 'package:better_player/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reddy/config/utils/constants.dart';
// import 'package:reddy/controllers/general/settings_controller.dart';
// import 'package:reddy/views/features/player/widgets/hls_video_player.dart';
// import 'package:reddy/views/test/test_web_view.dart';

// import 'test_controller.dart';

// class TestScreen extends GetView<TestController> {
//   TestScreen({super.key});

//   @override
//   final controller = Get.put(TestController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Test Screen"),
//       ),
//       body: WebViewExample(),
//       // body: AspectRatio(
//       //   aspectRatio: 16 / 9,
//       //   child: BetterPlayer.network(
//       //       "https://thumbs44.redgifs.com/ForestgreenJovialEkaltadeta-mobile.mp4?expires=1715158800&signature=v2:ba063b46be3e69c1640c554ead5577faee61899eb5bce8d81fa8bbd4c5ad2281&for=139.167.230&hash=7011125643"),
//       // )
//       // body: ListView.builder(
//       //   itemBuilder: (context, index) => Padding(
//       //     padding: const EdgeInsets.all(8.0),
//       //     child: Obx(
//       //       () => HlsVideoPlayer(
//       //         video: controller.videos[index],
//       //         thumbnailUrl: kDemoImgUrl,
//       //         postId: index.toString(),
//       //       ),
//       //     ),
//       //   ),
//       //   itemCount: controller.videos.length,
//       // ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: controller.floatingActionButtonPressed,
//       //   child: const Icon(Icons.add),
//       // )
//     );
//   }
// }
