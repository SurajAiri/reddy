import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reddy/controllers/general/home_controller.dart';
import 'package:reddy/controllers/general/settings_controller.dart';
import 'package:reddy/controllers/post/reddit_search_controller.dart';
import 'package:reddy/views/features/general/screens/settings_screen.dart';
import 'package:reddy/views/features/posts/screens/search_screen.dart';

import '../../views/features/general/screens/home_screen.dart';

class AllRoutes {
  // general
  static const homeScreen = "/home";
  static const settingsScreen = "/settings";

  // post
  static const postDetailsScreen = "/post";
  static const searchScreen = "/search";

  static List<GetPage> routes = [
    // general
    _buildGetPage(homeScreen, const HomeScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(
        () => HomeController(),
      );
    })),

    _buildGetPage(
      settingsScreen,
      const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SettingsController(),
        );
      }),
    ),

    // post
    _buildGetPage(searchScreen, const SearchScreen(),
        binding: BindingsBuilder(() {
      Get.put(RedditSearchController());
    })),
  ];

  static GetPage _buildGetPage(
    String name,
    Widget screen, {
    Bindings? binding,
  }) {
    return GetPage(
      name: name,
      page: () => screen,
      transition: Transition.cupertino,
      transitionDuration: const Duration(seconds: 1),
      binding: binding,
    );
  }
}
