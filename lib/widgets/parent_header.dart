import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import '../config/app_colors.dart';
import '../app/modules/parents_home/controllers/parents_home_controller.dart';

class ParentsHeader extends StatelessWidget {
  const ParentsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final parentController = Get.find<ParentsHomeController>();

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView to prevent overflow
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.baseBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum vertical space
            children: [
              const SizedBox(height: 50), // Reduced top spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100, // or a fixed width if needed
                        height: 45, // adjust height as needed
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.headerBtn),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Text(
                          'BALANCE',
                          // style: TextStyle(
                          //   color: Colors.black.withOpacity(0.7),
                          //   fontSize: 8,
                          //   fontWeight: FontWeight.bold,
                          // ),
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 7,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 10,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'MX\$ ',
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${parentController.parentAddWalletModel.value?.amount ?? "0.00"}',
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 100, // or a fixed width if needed
                        height: 45, // adjust height as needed
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.headerBtn),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Text(
                          'WALLET',
                          // style: TextStyle(
                          //   color: Colors.black.withOpacity(0.7),
                          //   fontSize: 8,
                          //   fontWeight: FontWeight.bold,
                          // ),
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 7,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 10,
                        child: Text(
                          'ADD',
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 8,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 100, // or a fixed width if needed
                        height: 45, // adjust height as needed
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.headerBtn),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 15,
                        child: Image.asset(
                          AppImages.shopped,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 10,
                        child: Text(
                          'MX\$ ',
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 8,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 15),
              // Parent image with circular container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0), // 5px padding
                  child: ClipOval(
                    child: Image.asset(
                      AppImages.profile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Parent Name',
                  style: AppTextStyles.MetropolisRegular.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor)),
              // Child images horizontal list
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 80, // Reduced height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          width: 50, // Reduced width
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Use minimum space
                            children: [
                              Container(
                                width: 55, // Reduced size
                                height: 55, // Reduced size
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(5.0), // 5px padding
                                  child: ClipOval(
                                    child: Image.asset(
                                      AppImages.profile,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text with constrained height and overflow handling
                              Text(
                                'Child',
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 7,
                                  color: AppColors.blackColor,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
