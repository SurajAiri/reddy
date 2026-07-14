import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/controllers/general/auth_controller.dart';

import 'controllers/general/settings_controller.dart';
import 'models/history/reddit_history_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init hive
  await Hive.initFlutter();
  // register adapters for reddit history
  Hive.registerAdapter(RedditHistoryModelAdapter());

  // open hive boxes
  await Hive.openBox<RedditHistoryModel>(kHistoryBoxHiveBox);

  Get.put(SettingsController(), permanent: true);

  // Load any previously saved Reddit login (cookies + UA) before the
  // first frame renders, so returning users skip the login screen
  // entirely instead of it flashing/re-authenticating every launch.
  final authController = Get.put(AuthController(), permanent: true);
  await authController.init();

  runApp(const ReddyApp());
}

class ReddyApp extends StatelessWidget {
  const ReddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return GetMaterialApp(
      getPages: AllRoutes.routes,
      initialRoute: authController.isLoggedIn
          ? AllRoutes.homeScreen
          : AllRoutes.redditInfo,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}
