import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reddy/config/routes/routes.dart';
import 'package:reddy/config/utils/constants.dart';

import 'controllers/general/settings_controller.dart';
import 'models/history/reddit_history_model.dart';

void main() async {
  Get.lazyPut(() => SettingsController());
  // init hive
  await Hive.initFlutter();
  // register adapters for reddit history
  Hive.registerAdapter(RedditHistoryModelAdapter());

  // open hive boxes
  await Hive.openBox<RedditHistoryModel>(kHistoryBoxHiveBox);

  runApp(const ReddyApp());
}

class ReddyApp extends StatelessWidget {
  const ReddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AllRoutes.routes,
      // home: TestScreen(),
      initialRoute: AllRoutes.homeScreen,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}
