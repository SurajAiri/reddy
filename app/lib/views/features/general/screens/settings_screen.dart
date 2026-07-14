import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/views/features/general/widgets/red_dropdown.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text(
              'Safe Content Only',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            trailing: Obx(
              () => Switch(
                value: controller.isSafeContentOnly.value,
                onChanged: (value) {
                  controller.isSafeContentOnly.value = value;
                },
              ),
            ),
          ),
          // sound
          ListTile(
            title: const Text(
              'Sound',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            trailing: Obx(
              () => Switch(
                value: controller.sound.value,
                onChanged: (value) {
                  controller.sound.value = value;
                },
              ),
            ),
          ),
          // autoplay
          ListTile(
            title: const Text(
              'Autoplay',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            trailing: Obx(
              () => Switch(
                value: controller.autoPlay.value,
                onChanged: (value) {
                  controller.autoPlay.value = value;
                },
              ),
            ),
          ),
          // image quality
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Image quality",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => RedDropdown(
                      values: ImageQuality.values
                          .map((e) => Utility.encodeImageQuality(e))
                          .toList(),
                      onChanged: (ind) {
                        controller.imageQuality.value =
                            ImageQuality.values[ind];
                      },
                      valueIndex: ImageQuality.values
                          .indexOf(controller.imageQuality.value),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
