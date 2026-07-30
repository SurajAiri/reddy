import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/utils/enums.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/auth_controller.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/views/features/general/widgets/red_dropdown.dart';

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Account",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Obx(() {
            final lastLogin = Get.find<AuthController>().lastLoginAt;
            return ListTile(
              title: const Text(
                'Reddit account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              subtitle: Text(
                lastLogin != null
                    ? 'Last logged in: ${_formatDateTime(lastLogin)}'
                    : 'Not logged in',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              trailing: TextButton.icon(
                onPressed: () => Get.find<AuthController>()
                    .goToLogin(forceAccountSwitch: true),
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Re-authenticate'),
              ),
            );
          }),
          const Divider(height: 24),
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
