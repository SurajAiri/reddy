import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/views/features/general/screens/home_screen.dart';
import 'package:reddy/views/test/test_player_screen.dart';
import 'package:reddy/views/test/test_screen.dart';

import 'controllers/general/settings_controller.dart';

void main() {
  Get.lazyPut(() => SettingsController());
  runApp(const ReddyApp());
}

class ReddyApp extends StatelessWidget {
  const ReddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AllRoutes.routes,
      home: TestScreen(),
      initialRoute: AllRoutes.homeScreen,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}
