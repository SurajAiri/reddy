import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/config/utils/utility.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/views/features/general/widgets/drawer_element.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});
  static int tapCount = 0;
  static DateTime? lastTapTime;
  // Initialize settings controller for premium status tracking;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.red[50],
      child: Column(
        children: [
          const SizedBox(
            width: double.maxFinite,
          ),
          SizedBox(
            height: 210,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[400],
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 251, 186, 186),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(-2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8, width: double.maxFinite),
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.red[100],
                      child: Image.asset(
                        AssetPaths.img.logo,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                    GestureDetector(
                    onTap: () {
                      final now = DateTime.now();
                      SettingsController settingsController = Get.find<SettingsController>();
                      if(settingsController.isPremium.value){
                        final now = DateTime.now();
                        if(lastTapTime == null || now.difference(lastTapTime!).inSeconds >= 2) {
                          UiUtility.showToast("You are already a premium user!");
                          lastTapTime = now;
                        }
                        return;
                        }
                      
                      final timeDiff = lastTapTime != null ? now.difference(lastTapTime!) : const Duration(seconds: 2);
                      
                      if (timeDiff.inSeconds < 1) {
                      tapCount++;
                      if (tapCount >= 7) {
                        tapCount = 0;
                        settingsController.isPremium.value = true;
                        settingsController.isSafeContentOnly.value = false;
                        UiUtility.showToast("Premium mode activated!");
                      }
                      } else {
                      tapCount = 1;
                      }
                      
                      lastTapTime = now;
                    },
                    child: const Text(
                      "Reddy",
                      style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      ),
                    ),
                    )
                ],
              ),
            ),
          ),
          // ListTile(
          //   title: const Text('Settings'),
          //   onTap: () {
          //     Get.back();
          //     Get.toNamed(AllRoutes.settingsScreen);
          //   },
          // ),
          DrawerElement(
            title: "Settings",
            iconData: Icons.settings,
            onPressed: () {
              Get.back();
              Get.toNamed(AllRoutes.settingsScreen);
            },
          ),
          DrawerElement(
            title: "More Apps",
            iconData: Icons.shop,
            onPressed: () async {
              UiUtility.showToast("Redirecting to play store...");
              try {
                if (!await launchUrl(Uri.parse(kPlayStoreDashboardLink))) {
                  UiUtility.showToast(
                    "Could not launch $kPlayStoreDashboardLink",
                    isError: true,
                  );
                }
              } catch (e) {
                UiUtility.showToast(
                  "An unexpected error occurred!\n$e",
                  isError: true,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
