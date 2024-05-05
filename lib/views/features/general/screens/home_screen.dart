import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:meme_life_v2/config/utils/asset_paths.dart';
import 'package:meme_life_v2/config/utils/enums.dart';
import 'package:meme_life_v2/controllers/general/home_controller.dart';
import 'package:meme_life_v2/views/features/general/widgets/post_field.dart';
import '../widgets/home_drawer.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            controller.scaffoldKey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                AssetPaths.logo,
                height: 32,
                // width: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: const Text(
          'Reddy',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.fetchPosts();
            },
            icon: Icon(Icons.replay_outlined),
          ),
          Obx(
            () => IconButton(
              onPressed: () {
                controller.settings.toggleSafeContentOnly();
              },
              icon: Icon(controller.settings.isSafeContentOnly.value
                  ? Icons.no_accounts
                  : Icons.safety_check),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemBuilder: (context, index) => PostField(
                  post: controller.posts.toList()[index],
                  safeContentOnly: controller.isSafeContentOnly.value,
                  imageQuality: controller.imageQuality.value,
                ),
                itemCount: controller.posts.length,
              ),
      ),
      drawer: const HomeDrawer(),
    );
  }
}
