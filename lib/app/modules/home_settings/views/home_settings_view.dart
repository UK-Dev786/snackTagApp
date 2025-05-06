import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_settings/views/cafeteria_setting_widget.dart';
import 'package:snacktag/app/modules/parents_history_list/views/parents_history_list_view.dart';
import 'package:snacktag/app/modules/profile/views/profile_view.dart';
import 'package:snacktag/app/modules/settings/views/settings_view.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

import '../controllers/home_settings_controller.dart';

class HomeSettingsView extends GetView<HomeSettingsController> {
  const HomeSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GetBuilder<HomeSettingsController>(
              init: HomeSettingsController(),
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
                    const SizedBox(
                        height: 40), // Spacing between title and list
                    CafeteriaSettingWidget(
                      labelName: "Profile",
                      onTap: () {
                        // Get.toNamed(Routes.PARENT_PROFILE);
                        Get.toNamed(Routes.SETTING_PARENT_PROFILE);
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "History",
                      onTap: () {
                        // Get.toNamed(Routes.CAFETERIA_ADD_STAFF, arguments: true);
                        // Get.toNamed(Routes.CAFETERIA_STAFF_LIST);
                        Get.toNamed(Routes.PARENTS_HISTORY);
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
                      labelName: "Delete Account",
                      onTap: () {
                        Get.dialog(
                          Obx(() => controller.isLoading.value
                              ? Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),
                                          Text("Deleting account...",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : AlertDialog(
                                  title: Text("Delete Account",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.MetropolisRegular
                                          .copyWith(
                                        color: Colors.red,
                                        fontSize: 16,
                                      )),
                                  content: Text(
                                      "Are you sure you want to delete your account? This action cannot be undone.",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.MetropolisRegular
                                          .copyWith(
                                        color: const Color(0xFF4A4B4D),
                                        fontSize: 15,
                                      )),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back(); // Close dialog
                                      },
                                      child: Text("Cancel",
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            color: const Color(0xFF4A4B4D),
                                            fontSize: 14,
                                          )),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await controller.deleteAccount();
                                        Get.back(); // Close confirmation dialog
                                      },
                                      child: Text("Delete",
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            color: Colors.red,
                                            fontSize: 14,
                                          )),
                                    ),
                                  ],
                                )),
                          barrierDismissible: false,
                        );
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Sign Out",
                      onTap: () {
                        controller.logout();
                        // Get.offAllNamed(Routes.SPLASH);
                        // print("object Pressed");
                      },
                    ),
                  ],
                );
              }),
        )
        // Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        //   Expanded(
        //     child: Obx(
        //       () => IndexedStack(
        //         index: controller
        //             .selectedIndex.value, // Bind the selected index to controller
        //         children: const [
        //           // First child
        //           SettingsView(),
        //
        //           // Third child
        //           ProfileView(),
        //
        //           ParentsHistoryListView(),
        //         ],
        //       ),
        //     ),
        //   ),
        // ]),
        );
  }
}
