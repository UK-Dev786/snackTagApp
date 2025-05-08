import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/controllers/cafeteria_home_settings_controller.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/config/validation.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/widgets/custom_back_button.dart';
import 'package:snacktag/widgets/custom_password_text_field.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/cafeteria_add_staff_controller.dart';

class CafeteriaAddStaffView extends GetView<CafeteriaAddStaffController> {
  // Constructor: Initialize both 'isEdit' and 'staffModelL' from Get.arguments
  const CafeteriaAddStaffView({super.key});
  @override
  Widget build(BuildContext context) {
    // final addStaffController = Get.find<CafeteriaHomeSettingsController>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Profile Picture

              const SizedBox(
                height: 25,
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
                        // addStaffController.updateSelectedIndex(0);
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        margin: const EdgeInsets.only(top: 16), // Add some margin if needed
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                          color: Colors.white, // Background color for the container
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
                  Text(
                    "Add Staff",
                    style: AppTextStyles.MetropolisBold.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF434343),
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
              const SizedBox(height: 35),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
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
                                    color:
                                        Colors.black.withOpacity(0.1), // Shadow color with opacity
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
                                              return const Center(
                                                  child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return _buildPlaceholder();
                                            },
                                          )
                                        : _buildPlaceholder(),
                                // Image.asset(
                                //   'assets/images/userimg.png', // Replace with the actual image URL
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: CustomBackButton(
                                  onTap: () => controller.pickImage(),
                                  widget: const Icon(Icons.add)))
                        ],
                      ),
                      // if (isEdit) const SizedBox(height: 10),
                      // if (isEdit)
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       const Icon(
                      //         Icons.edit,
                      //         color: Color(0xFFFF9A0D),
                      //         size: 16,
                      //       ),
                      //
                      //       const SizedBox(width: 5),
                      //
                      //       // Edit Profile
                      //       GestureDetector(
                      //         onTap: () {
                      //           // Handle edit profile action
                      //         },
                      //         child: Text(
                      //           "Edit Profile",
                      //           style: AppTextStyles.MetropolisMedium.copyWith(
                      //             color: const Color(0xFFFF9A0D),
                      //             fontSize: 12,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      const SizedBox(height: 20),
                      SimpleTextFieldWithOutSuffixWidget(
                        hintText: 'Staff Name',
                        controller: controller.nameController,
                      ),
                      const SizedBox(height: 20),
                      SimpleTextFieldWithOutSuffixWidget(
                        // validator: Validator.isValidEmail,
                        hintText: 'Email',
                        controller: controller.emailController,
                      ),
                      const SizedBox(height: 20),
                      // SimpleTextFieldWithOutSuffixWidget(
                      //   hintText: 'Phone',
                      //   keyboardType: TextInputType.number,
                      //   controller: controller.phoneController,
                      // ),
                      // Phone number field
                      Container(
                        height: 56,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 30, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            labelStyle: AppTextStyles.MetropolisRegular.copyWith(
                              color: const Color(0xFFB6B7B7),
                              fontSize: 12,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: InputBorder.none,
                            counterText: '',
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          initialCountryCode: 'PK',
                          onChanged: (phone) {
                            controller.phoneController.text = phone.completeNumber;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // SimpleTextFieldWithOutSuffixWidget(
                      //   hintText: 'Password',
                      //   controller: controller.passwordController,
                      //   isVisible: true,
                      // ),
                      CustomPasswordFieldWidget(
                        hintText: "Password",
                        controller: controller.passwordController,
                        isVisible: false,
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => CustomButton1(
                            text: 'Continue',
                            onPressed: () async {
                              if (controller.nameController.text.isEmpty) {
                                Get.snackbar("Validation Error", "Staff name is required");
                                return;
                              }
                              
                              if (controller.emailController.text.isEmpty) {
                                Get.snackbar("Validation Error", "Email is required");
                                return;
                              }
                              
                              if (controller.phoneController.text.isEmpty) {
                                Get.snackbar("Validation Error", "Phone number is required");
                                return;
                              }
                              
                              if (controller.passwordController.text.isEmpty) {
                                Get.snackbar("Validation Error", "Password is required");
                                return;
                              }
                              
                              if (!(Validator.isValidEmail(controller.emailController.text))) {
                                Get.snackbar("Validation Error", "Please Enter Valid Email");
                                return;
                              }
                              
                              if (controller.passwordController.text.length < 6) {
                                Get.snackbar("Validation Error", "Password must be at least 6 characters");
                                return;
                              }
                              
                              await controller.addStaffData();
                            },
                            isLoading: controller.isLoading.value),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder Widget Function
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icon/camera.png',
          width: 40,
        ),
      ],
    );
  }
}
