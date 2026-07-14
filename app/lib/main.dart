import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/constants.dart';
import 'package:reddy/views/features/posts/screens/reddit_info_screen.dart';
import 'package:reddy/views/features/test_screen.dart';

import 'controllers/general/settings_controller.dart';
import 'models/history/reddit_history_model.dart';
import 'views/test/test_screen.dart';

void main() async {
  // init hive
  await Hive.initFlutter();
  // register adapters for reddit history
  Hive.registerAdapter(RedditHistoryModelAdapter());

  // open hive boxes
  await Hive.openBox<RedditHistoryModel>(kHistoryBoxHiveBox);

  // Get.lazyPut(() => SettingsController());
  Get.put(SettingsController(), permanent: true);
  runApp(const ReddyApp());
}

class ReddyApp extends StatelessWidget {
  const ReddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AllRoutes.routes,
      // home: RedditInfoScreen(),
      initialRoute: AllRoutes.homeScreen,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}
