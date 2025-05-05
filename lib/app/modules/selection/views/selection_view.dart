import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import 'package:snacktag/widgets/selection_tile.dart';

import '../controllers/selection_controller.dart';

class SelectionView extends GetView<SelectionController> {
  const SelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientStartColor,
              AppColors.gradientEndColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Spacer(flex: 8), // Keeps LUNCH R centered at the top
              // Center(
              //   child: Text(
              //     'Snack Tag',
              //     style: AppTextStyles.MetropolisRegularItalic.copyWith(
              //         color: AppColors.whiteColor,
              //         fontSize: 45,
              //     ),
              //   ),
              // ),
              Image.asset("assets/images/Snacktag_logo.png",height: 100,),

              const Spacer(flex: 8), // Push "TYPE SELECTION" further down

              Text(
                'Type Selection',
                style: AppTextStyles.MetropolisBold.copyWith(
                  fontSize: 22,
                  color: AppColors.whiteColor, // Keep text white
                ),
              ),

              const SizedBox(height: 60),

              Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectionTile(
                      imgPath: AppImages.parent,
                      text: 'Parents',
                      isSelected: controller.isParentSelected.value,
                      onTap: () => controller.isParentSelected.value = true,
                    ),
                    const SizedBox(width: 20),
                    SelectionTile(
                      imgPath: AppImages.cafe,
                      text: 'Cafeteria',
                      isSelected: !controller.isParentSelected.value,
                      onTap: () => controller.isParentSelected.value = false,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3), // Balanced space after the tiles

              CustomButton(
                isBackColor: false,
                text: 'CONTINUE',
                fontSize: 16,
                onPressed: () {
                  if (controller.isParentSelected.value) {
                    Get.toNamed(Routes.PHONE_AUTHENTICATION);
                  } else {
                    Get.toNamed(Routes.CAFETERIA_PHONE_AUTHENICATION);
                  }
                },
                isLoading: false.obs,
              ),
              const Spacer(flex: 1), // Space below the button
            ],
          ),
        ),
      ),
    );
  }
}
