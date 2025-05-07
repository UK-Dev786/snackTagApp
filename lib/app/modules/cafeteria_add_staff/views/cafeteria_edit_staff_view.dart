import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_add_staff/controllers/cafeteria_edit_staff_controller.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/controllers/cafeteria_home_settings_controller.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/config/validation.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/widgets/custom_back_button.dart';
import 'package:snacktag/widgets/custom_password_text_field.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/cafeteria_add_staff_controller.dart';

class CafeteriaEditStaffView extends GetView<CafeteriaEditStaffController> {
  final StaffModel staffModel;

  CafeteriaEditStaffView({super.key})
      : staffModel = Get.arguments?['staffModelL'] ?? StaffModel();

  @override
  Widget build(BuildContext context) {
    // Set the staff data when the screen builds
    // controller.setStaffData(staffModel);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Builder(builder: (context) {
            return Column(
              children: [
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
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
                    Expanded(
                      child: Center(
                        child: Text(
                          "Update Profile",
                          style: AppTextStyles.MetropolisBold.copyWith(
                            fontSize: 18,
                            color: const Color(0xFF434343),
                          ),
                        ),
                      ),
                    ),
                    // Empty container with same width as back button for balance
                    SizedBox(width: 35),
                  ],
                ),
                const SizedBox(height: 35),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Picture
                        Obx(
                          () => Stack(
                            children: [
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
                                child: controller.imageUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          controller.imageUrl.value,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 127,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return _buildPlaceholder();
                                          },
                                        ),
                                      )
                                    : _buildPlaceholder(),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CustomBackButton(
                                  onTap: () => controller.pickImage(),
                                  widget: const Icon(Icons.edit),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        SimpleTextFieldWithOutSuffixWidget(
                          hintText: 'Staff Name',
                          controller: controller.nameController,
                        ),
                        const SizedBox(height: 20),
                        SimpleTextFieldWithOutSuffixWidget(
                          hintText: 'Email',
                          isReadOnly: true,
                          controller: controller.emailController,
                        ),
                        const SizedBox(height: 20),
                        SimpleTextFieldWithOutSuffixWidget(
                          hintText: 'Phone',
                          isReadOnly: true,
                          controller: controller.phoneController,
                        ),
                        const SizedBox(height: 20),
                        // SimpleTextFieldWithOutSuffixWidget(
                        //   hintText: 'Password',
                        //   controller: controller.passwordController,
                        // ),
                        CustomPasswordFieldWidget(
                          hintText: "Password",
                          controller: controller.passwordController,
                          isVisible: false,
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => CustomButton1(
                            text: 'Save',
                            onPressed: () async {
                              await controller.editStaffData(staffModel.id!);
                            },
                            isLoading: controller.isLoading.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
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
