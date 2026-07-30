import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/services/subranking/subranking_api.dart';
import 'package:reddy/services/subranking/utility.dart';

import 'test_controller.dart';

class TestScreen extends GetView<TestController> {
  TestScreen({super.key});

  @override
  final controller = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async{
            // Handle button press
            // controller.handleButtonPress();
            final res =await SubrankingApi.fetchSubredditNames(type: SubrankingType.random,category: SubrankingCategory.nsfw, nsfw: true, limit: 10,filter:5000);
            print("Response: $res");
          },
          child: const Text('Test Button'),
        ),
      ),
    );
  }
}
