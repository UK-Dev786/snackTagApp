import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_child_verification_home/controllers/cafeteria_child_verification_home_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
// // import 'package:snacktag/app/routes/app_routes.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/cafeteria_child_verification_controller.dart';

class CafeteriaChildVerificationView extends StatelessWidget {
  const CafeteriaChildVerificationView({super.key});
  @override
  Widget build(BuildContext context) {
    // Define the controller for the email text field
    //     final controller = Get.find<CafeteriaChildVerificationController>();

    // final homeController = Get.find<CafeteriaChildVerificationHomeController>();

    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GetBuilder<CafeteriaChildVerificationController>(
                init: CafeteriaChildVerificationController(),
                builder: (childVerificationController) {
                  return Column(
                    children: [
                      const SizedBox(height: 160),

                      // Add auth image at the top
                      Center(
                        child: Image.asset(
                          AppImages.authImg,
                          width: 100,
                          height: 100,
                        ),
                      ),

                      const SizedBox(height: 45),

                      // Heading text
                      Text(
                        'IDENTIFICATION',
                        style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 18,
                          color: const Color(0xFF434343),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Please Enter Child ID',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.MetropolisRegular.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF858585),
                        ),
                      ),

                      const SizedBox(height: 60),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: SimpleTextFieldWithOutSuffixWidget(
                          hintText: 'Child School ID',
                          controller:
                              childVerificationController.schoolIdController,
                          keyboardType: TextInputType.text,
                          onChanged: (value) =>
                              childVerificationController.validateSchoolId(),
                        ),
                      ),

                      // Error message
                      Obx(() => Visibility(
                            visible: childVerificationController
                                .errorMessage.value.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                childVerificationController.errorMessage.value,
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          )),

                      const SizedBox(height: 20),

                      Obx(() => CustomButton1(
                            text: 'IDENTIFY',
                            onPressed: () async {
                              // Unfocus before starting async operation

                              if (childVerificationController.isValid.value) {
                                bool success = await childVerificationController
                                    .fetchCafateriaChildren();
                                if (success) {
                                  Get.toNamed(
                                    Routes.CHILD_VERIFICATION_UPLOAD_INFO,
                                    arguments: {
                                      'childrenList':
                                          childVerificationController
                                              .childrenList,
                                    },
                                  );
                                }
                              } else {
                                childVerificationController.verifyChildId();
                              }
                            },
                            isLoading:
                                childVerificationController.isLoading.value,
                            height: 60.0, // Set button height to 60
                            fontSize: 18.0,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                          )),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
