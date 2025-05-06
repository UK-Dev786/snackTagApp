import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import '../controllers/setting_parent_profile_controller.dart';

class SettingParentProfileView extends GetView<SettingParentProfileController> {
  const SettingParentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: const Text('Edit Profile'),
      //   centerTitle: true,
      // ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        // historyController.updateSelectedIndex(0);
                        // historyController.updateSelectedIndex(0);
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        margin: const EdgeInsets.only(
                            top: 16), // Add some margin if needed
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                          color: Colors
                              .white, // Background color for the container
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/icon/back.png",
                            height: 15, // Set the height to 15
                            width: 10, // Set the width to 15
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text('Edit Profile',
                      style: AppTextStyles.MetropolisBold.copyWith(
                        fontSize: 18,
                      )),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 100,
              ),
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: controller.pickImage,
                  child: Stack(
                    children: [
                      Obx(() => CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                controller.selectedImage.value != null
                                    ? FileImage(controller.selectedImage.value!)
                                        as ImageProvider
                                    : controller.currentImageUrl.value != null
                                        ? NetworkImage(
                                            controller.currentImageUrl.value!)
                                        : null,
                            child: controller.isImageLoading.value
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : (controller.selectedImage.value == null &&
                                        controller.currentImageUrl.value ==
                                            null)
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.hintText,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),

              SimpleTextFieldWithOutSuffixWidget(
                controller: controller.nameController,
              ),
              const SizedBox(height: 24),

              Obx(() => CustomButton1(
                  text: 'UPDATE PROFILE',
                  onPressed: controller.updateProfile,
                  isLoading: controller.isLoading.value))
            ],
          ),
        );
      }),
    );
  }
}
