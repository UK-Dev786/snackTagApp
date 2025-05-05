import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/home_settings/controllers/home_settings_controller.dart';
import 'package:snacktag/app/modules/home_settings/views/home_settings_view.dart';
import 'package:snacktag/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:snacktag/app/modules/notifications/views/notifications_view.dart';
import 'package:snacktag/app/modules/parents_history/controllers/parents_history_controller.dart';
import 'package:snacktag/app/modules/parents_history/views/parents_history_view.dart';
import 'package:snacktag/app/modules/parents_home/controllers/parents_home_controller.dart';
import 'package:snacktag/app/modules/parents_home/views/parents_home_view.dart';
import 'package:snacktag/config/app_images.dart';

class LandingPageController extends GetxController {
  final List<String> images = [
    AppImages.homeIcon,
    AppImages.upComing,
    AppImages.notificationsIcon,
    AppImages.settingsIcon,
  ];

  final List<Widget> screens = [
    const ParentsHomeView(),
    GetBuilder<ParentsHistoryController>(
      init: ParentsHistoryController(),
      builder: (_) => const ParentsHistoryView(),
    ),
    GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (_) => const NotificationsView(),
    ),
    GetBuilder<HomeSettingsController>(
      init: HomeSettingsController(),
      autoRemove: false,
      builder: (_) => const HomeSettingsView(),
    ),
  ];

  // Selected index (Reactive variable)
  var selectedIndex = 0.obs;

  // Function to update the selected index
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
