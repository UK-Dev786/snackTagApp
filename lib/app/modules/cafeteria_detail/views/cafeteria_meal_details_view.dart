import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';

import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/cafeteria_detail_controller.dart';

class CafeteriaDetailView extends GetView<CafeteriaDetailController> {
  const CafeteriaDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ListView(
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
                      'CAFETERIA DETAILS',
                      style: AppTextStyles.MetropolisMedium.copyWith(color: const Color(0xFF434343), fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 127, // Fixed height
                      decoration: BoxDecoration(
                        color: Colors.white, // Set background color
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3), // Shadow color
                            spreadRadius: 2, // Spread of the shadow
                            blurRadius: 6, // Blur intensity of the shadow
                            offset: const Offset(0, 3), // Offset of the shadow (X, Y)
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20), // Optional: round corners
                      ),
                      child: Obx(() => controller.selectedImage.value != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(20), //
                        child: Image.file(
                          controller.selectedImage.value!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 127,
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/icon/camera.png',
                              width: 60,
                              height: 50,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Upload Cafeteria Photo',
                            style: AppTextStyles.MetropolisRegular.copyWith(fontSize: 12, color: const Color(0xFFB6B7B7)),
                          )
                        ],
                      ),)
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SimpleTextFieldWithOutSuffixWidget(controller: controller.cafeNameController, hintText: 'Cafeteria Name'),
                  const SizedBox(
                    height: 16,
                  ),
                  SimpleTextFieldWithOutSuffixWidget(controller: controller.schoolNameController, hintText: 'School / Collage Name'),
                  const SizedBox(
                    height: 30,
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
      ),
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('PickedFile Path${pickedFile.path}');
      controller.selectedImage.value = File(pickedFile.path);
    }
  }
}
