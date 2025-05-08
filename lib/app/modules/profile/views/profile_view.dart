import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/controllers/cafeteria_home_settings_controller.dart';
import 'package:snacktag/app/modules/home_settings/controllers/home_settings_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
// import 'package:snacktag/app/routes/app_routes.dart';t';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 35,
                    width: 35,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/icon/back.png",
                        height: 15,
                        width: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 102,
                height: 102,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: controller.userProfile.value?.cafeteriaLogo != null
                      ? Image.network(
                          controller.userProfile.value!.cafeteriaLogo!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFFFC6011).withOpacity(0.2),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/userimg.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/userimg.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.ADMIN_SETTING_PROFILE),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Color(0xFFFF9A0D),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Edit Profile",
                      style: AppTextStyles.MetropolisMedium.copyWith(
                        color: const Color(0xFFFF9A0D),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Hi there ${controller.userProfile.value?.cafeteriaName ?? 'User'}!",
                style: AppTextStyles.MetropolisBold.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              SimpleTextFieldWithOutSuffixWidget(
                // hintText: controller.userProfile.value?.schoolName ?? 'School/College Name',
                hintText: 'School/College Name',
                readOnly: true,
                controller: TextEditingController(
                  text: controller.userProfile.value?.schoolName ?? '',
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
