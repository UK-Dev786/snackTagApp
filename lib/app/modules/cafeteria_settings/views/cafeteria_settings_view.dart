import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/controllers/cafeteria_home_settings_controller.dart';
import 'package:snacktag/app/modules/cafeteria_settings/views/cafeteria_setting_widget.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';

import '../controllers/cafeteria_settings_controller.dart';

class CafeteriaSettingsView extends GetView<CafeteriaSettingsController> {
  const CafeteriaSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    final controllerHome = Get.find<CafeteriaHomeSettingsController>();

    final List<String> settings = [
      "Profile",
      "Add Staff members",
      "History",
      "Privacy Policy",
      "Terms & Conditions",
      "Sign Out",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: SimpleCustomAppBar(optionalText: 'SETTINGS'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
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

            // ListView of Settings
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        controllerHome.updateSelectedIndex(1);
                      } else if (index == 5) {
                        controller.logout();
                      } else if (index == 1) {
                        controllerHome.updateSelectedIndex(2);
                      } else if (index == 2) {
                        controllerHome.updateSelectedIndex(5);
                      }
                      //else if (index == 4) {
                      //   Get.toNamed('/signout');
                      // }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Orange Circular Dot
                              Image.asset(
                                'assets/icon/dot.png',
                                width: 10,
                                height: 10,
                              ),
                              const SizedBox(width: 16), // Spacing between dot and text
                              // Title
                              Expanded(
                                child: Text(
                                  settings[index],
                                  style: AppTextStyles.MetropolisRegular.copyWith(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Trailing Arrow
                              Image.asset(
                                'assets/icon/arrow.png',
                                width: 24,
                                height: 17,
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Color(0xFFEEEEEE),
                          thickness: 1,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            // define the row of setting page
            const SizedBox(height: 40), // Spacing between title and list
            // CafeteriaSettingWidget(
            //   labelName: "Profile",
            //   onTap: () {
            //    Get.toNamed(Routes.PROFILE);
            //   },
            // ),
            // CafeteriaSettingWidget(labelName: "Add Staff members",onTap: (){
            //   print(" Pressed");
            // },),
            // CafeteriaSettingWidget(labelName: "History",onTap: (){
            //   print("object Pressed");
            // },),
            // CafeteriaSettingWidget(labelName: "Privacy Policy",onTap: (){
            //   print("object Pressed");
            // },),
            // CafeteriaSettingWidget(labelName: "Terms & Conditions",onTap: (){
            //   print("object Pressed");
            // },),
            // CafeteriaSettingWidget(labelName: "Sign Out",onTap: (){
            //   print("object Pressed");
            // },),
          ],
        ),
      ),
    );
  }
}
