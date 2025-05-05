import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/modules/parents_profile/controller/parent_profile_controller.dart';
import 'package:snacktag/app/modules/staff_home_settings/controllers/staff_home_settings_controller.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_back_button.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

class ParentsProfileView extends GetView<ParentsProfileController> {
  const ParentsProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<ParentsProfileController>(
            init: ParentsProfileController(),
            builder: (context) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'PROFILE',
                              style: AppTextStyles.MetropolisMedium.copyWith(
                                  color: const Color(0xFF434343), fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Obx(
                                  () => Container(
                                    width: 102,
                                    height: 102,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3, // Border with a width of 3
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1), // Shadow color with opacity
                                          blurRadius: 5, // Blur effect
                                          spreadRadius: 2, // Spread radius
                                          offset: const Offset(0, 1), // Position of the shadow (x, y)
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: controller.selectedImage.value != null
                                          ? Image.file(
                                              controller.selectedImage.value!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 127,
                                            )
                                          : controller.imageUrl.value.isNotEmpty
                                              ? Image.network(
                                                  controller.imageUrl.value,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 127,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return const Center(child: CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.error_outline_outlined,
                                                        size: 20); //_buildPlaceholder();
                                                  },
                                                )
                                              : Image.asset(
                                                  // 'assets/images/userimg.png', // Replace with the actual image URL
                                                  'assets/images/profile_emoji.png', // Replace with the actual image URL
                                                  fit: BoxFit.cover,
                                                ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CustomBackButton(
                                        onTap: () => controller.pickImage(), widget: const Icon(Icons.add)))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          SimpleTextFieldWithOutSuffixWidget(
                              controller: controller.parentNameController, hintText: 'Please Enter Name'),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Obx(() => CustomButton1(
                        text: 'CONTINUE',
                        onPressed: () {
                          controller.validateAndContinue();
                          // Get.toNamed(Routes.CAFETERIA_MEAL_DETAILS);
                        },
                        isLoading: controller.isLoading.value))
                  ],
                ),
              );
            }),
      ),
    );
  }
}
