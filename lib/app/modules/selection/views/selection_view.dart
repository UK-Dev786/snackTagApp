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
              AppColors.gradientEndColor,
              AppColors.gradientStartColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Spacer(flex: 14), // Keeps LUNCH R centered at the top
              // Center(
              //   child: Text(
              //     'Snack Tag',
              //     style: AppTextStyles.MetropolisRegularItalic.copyWith(
              //         color: AppColors.whiteColor,
              //         fontSize: 45,
              //     ),
              //   ),
              // ),
              Image.asset(
                "assets/images/Snacktag_logo.png",
                height: 100,
              ),

              const Spacer(flex: 10), // Push "TYPE SELECTION" further down

              Text(
                'TYPE SELECTION',
                style: AppTextStyles.MetropolisRegular.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor, // Keep text white
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectionTile(
                      imgPath: AppImages.newUser,
                      // text: 'Parents',
                      isSelected: controller.isParentSelected.value,
                      onTap: () {
                        controller.isParentSelected.value = true;
                        Get.toNamed(Routes.PHONE_AUTHENTICATION);
                      },
                    ),
                    const SizedBox(width: 10),
                    SelectionTile(
                      imgPath: AppImages.newCafe,
                      // text: 'Cafeteria',
                      isSelected: !controller.isParentSelected.value,
                      onTap: () {
                        controller.isParentSelected.value = false;
                        Get.toNamed(Routes.CAFETERIA_PHONE_AUTHENICATION);
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(
                  flex: 4), // Increased space after removing the button
            ],
          ),
        ),
      ),
    );
  }
}
