import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_settings/views/cafeteria_setting_widget.dart';
import 'package:snacktag/app/modules/profile/views/profile_view.dart';
import 'package:snacktag/app/modules/staff_history_calender/views/staff_history_calender_view.dart';
import 'package:snacktag/app/modules/staff_profile/views/staff_profile_view.dart';
import 'package:snacktag/app/modules/staff_settings/controllers/staff_settings_controller.dart';
import 'package:snacktag/app/modules/staff_settings/views/staff_settings_view.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';

import '../controllers/staff_home_settings_controller.dart';

class StaffHomeSettingsView extends GetView<StaffHomeSettingsController> {
  const StaffHomeSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GetBuilder<StaffSettingsController>(
            init: StaffSettingsController(),
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 70,
                  ),

                  // Settings Title
                  Text(
                    'SETTINGS', // Title text
                    style: AppTextStyles.MetropolisMedium.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF434343),
                    ),
                  ),
                  // const SizedBox(height: 56), // Spacing between title and list

                  // define the row of setting page
                  const SizedBox(height: 40), // Spacing between title and list
                  CafeteriaSettingWidget(
                    labelName: "Profile",
                    onTap: () {
                      Get.toNamed(Routes.STAFF_PROFILE);
                    },
                  ),
                  CafeteriaSettingWidget(
                    labelName: "Upcoming",
                    onTap: () {
                      // Get.toNamed(Routes.CAFETERIA_ADD_STAFF, arguments: true);
                      Get.toNamed(Routes.STAFF_HISTORY_CALENDER);
                    },
                  ),
                  // CafeteriaSettingWidget(
                  //   labelName: "Privacy Policy",
                  //   onTap: () {
                  //     print("object Pressed");
                  //   },
                  // ),
                  CafeteriaSettingWidget(
                    labelName: "Privacy Policy",
                    onTap: () {
                      print("object Pressed");
                    },
                  ),
                  CafeteriaSettingWidget(
                    labelName: "Terms & Conditions",
                    onTap: () {
                      print("object Pressed");
                    },
                  ),
                  CafeteriaSettingWidget(
                    labelName: "Sign Out",
                    onTap: () {
                      controller.removeUserId();
                      Get.offAllNamed(Routes.SPLASH);
                      print("object Pressed");
                    },
                  ),
                ],
              );
            }
        ),
      )
      // Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      //   Expanded(
      //     child: Obx(
      //       () => IndexedStack(
      //         index: controller
      //             .selectedIndex.value, // Bind the selected index to controller
      //         children: const [
      //           // First child
      //           StaffSettingsView(),
      //
      //           // Third child
      //           StaffProfileView(),
      //
      //           StaffHistoryCalenderView(),
      //         ],
      //       ),
      //     ),
      //   ),
      // ]),
    );
  }
}
