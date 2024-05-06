import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/asset_paths.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/config/utils/ui_utility.dart';
import 'package:reddy/views/features/general/widgets/drawer_element.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

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
                        AssetPaths.logo,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Reddy",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
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
