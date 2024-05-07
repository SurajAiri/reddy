import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/views/features/player/widgets/hls_video_player.dart';

import 'test_controller.dart';

class TestScreen extends GetView<TestController> {
  TestScreen({super.key});

  @override
  final controller = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: GetBuilder<SettingsController>(
            builder: (controller) =>
                Text(controller.focusPostId.value.toString()),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => HlsVideoPlayer(
                video: controller.videos[index],
                thumbnailUrl: kDemoImgUrl,
                postId: index.toString(),
              ),
            ),
          ),
          itemCount: controller.videos.length,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.floatingActionButtonPressed,
          child: const Icon(Icons.add),
        ));
  }
}
