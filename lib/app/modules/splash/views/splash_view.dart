import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/splash/controllers/splash_controller.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(), // Initialize the controller
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              // Gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gradientStartColor,
                      AppColors.gradientEndColor,
                    ],
                  ),
                ),
              ),
              // Centered text
              Padding(
                padding: const EdgeInsets.only(bottom: 200),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text(
                      //   'Snack Tag',
                      //   style: AppTextStyles.MetropolisRegularItalic.copyWith(
                      //     color: AppColors.whiteColor,
                      //     fontSize: 45,
                      //   ),
                      // ),
                      Image.asset("assets/images/Snacktag_logo.png",height: 100,),
                      Text(
                        'Tasty & Healthy',
                        style: AppTextStyles.MetropolisRegular.copyWith(
                          fontSize: 16,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Positioned image at the right-end bottom
              Positioned(
                bottom: -53, // Position it at the bottom
                right: -53, // Align it to the right edge
                left: 0,
                child: Image.asset(
                  'assets/images/splash.png', // Replace with your image path
                  fit: BoxFit
                      .cover, // Ensure the image maintains its aspect ratio
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
