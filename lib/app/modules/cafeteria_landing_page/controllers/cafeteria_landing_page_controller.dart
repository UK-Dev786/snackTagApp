import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_child_verification_home/controllers/cafeteria_child_verification_home_controller.dart';
import 'package:snacktag/app/modules/cafeteria_child_verification_home/views/cafeteria_child_verification_home_view.dart';
import 'package:snacktag/app/modules/cafeteria_history/controllers/cafeteria_history_controller.dart';
import 'package:snacktag/app/modules/cafeteria_history/views/cafeteria_history_view.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/controllers/cafeteria_home_settings_controller.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/views/cafeteria_home_settings_view.dart';
import 'package:snacktag/app/modules/cafeteria_menu_page/controllers/cafeteria_menu_page_controller.dart';
import 'package:snacktag/app/modules/cafeteria_menu_page/views/cafeteria_menu_page_view.dart';
import 'package:snacktag/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:snacktag/app/modules/notifications/views/notifications_view.dart';

class CafeteriaLandingPageController extends GetxController {
  final List<String> imagePaths = [
    'assets/icon/home.png',
    'assets/icon/file.png',
    'assets/icon/active.png',
    'assets/icon/settings.png',
  ];

  final List<Widget> screens = [
    GetBuilder<CafeteriaMenuPageController>(
      init: CafeteriaMenuPageController(),
      builder: (_) => const CafeteriaMenuPageView(),
    ),
    GetBuilder<CafeteriaHistoryController>(
      init: CafeteriaHistoryController(),
      builder: (_) => const CafeteriaHistoryView(),
    ),
    GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (_) => const NotificationsView(),
    ),
    GetBuilder<CafeteriaHomeSettingsController>(
      init: CafeteriaHomeSettingsController(),
      builder: (_) => const CafeteriaHomeSettingsView(),
    ),
  ];

  // Selected index (Reactive variable)
  var selectedIndex = 0.obs;

  // Function to update the selected index
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
