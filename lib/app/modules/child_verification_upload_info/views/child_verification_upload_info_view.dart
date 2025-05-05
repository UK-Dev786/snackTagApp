import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:snacktag/app/modules/cafeteria_child_verification_home/controllers/cafeteria_child_verification_home_controller.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import 'package:intl/intl.dart';
import '../controllers/child_verification_upload_info_controller.dart';

class ChildVerificationUploadInfoView extends StatelessWidget {
  const ChildVerificationUploadInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    // final homeController = Get.find<CafeteriaChildVerificationHomeController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: GetBuilder<ChildVerificationUploadInfoController>(
            init: ChildVerificationUploadInfoController(),
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 35),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          // controller.updateSelectedIndex(0);
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
                  ),

                  // Settings Title
                  Center(
                    child: Text(
                      'UPLOAD INFO', // Title text
                      style: AppTextStyles.MetropolisMedium.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF434343),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Spacing between title and list
                  // Row with month/year and calendar icon
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: DateFormat('MMMM ').format(DateTime.now()),
                            style: AppTextStyles.RobotoLight.copyWith(
                              fontSize: 18,
                              color: const Color(0xFF2E2E2E),
                            ),
                          ),
                          TextSpan(
                            text: '${DateTime.now().year}',
                            style: AppTextStyles.RobotoBold.copyWith(
                              fontSize: 18,
                              color: const Color(0xFF2E2E2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hardcoded subtitle
                  ),

                  const SizedBox(height: 5), // Spacing between date and image

                  // Center circular image
                  Center(
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white, // White border color
                          width: 3, // Border width
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.25), // Shadow color with transparency
                            blurRadius: 8, // Spread of the shadow
                            offset: const Offset(
                                0, 4), // Position of the shadow (x, y)
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: controller
                                .childrenList.first.childImageUrl!.isNotEmpty
                            ? Image.network(
                                controller.childrenList.first.childImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 127,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                      Icons.error_outline_outlined,
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

                  // First custom Row with text and image
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Upload Student Photo',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Second custom Row with container, image, and texts
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 166,
                          height: 183,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.9), // Optional background color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Image taking 80% of the container height

                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: controller
                                                .childrenList
                                                .first
                                                .selectedMealMenuData!
                                                .first
                                                .imageUrl !=
                                            null &&
                                        controller
                                            .childrenList
                                            .first
                                            .selectedMealMenuData!
                                            .first
                                            .imageUrl!
                                            .isNotEmpty
                                    ? Image.network(
                                        controller
                                            .childrenList
                                            .first
                                            .selectedMealMenuData!
                                            .first
                                            .imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 153,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const SizedBox(
                                            height: 153,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const SizedBox(
                                            height: 153,
                                            child: Center(
                                              child: Icon(
                                                  Icons.error_outline_outlined,
                                                  size: 20),
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox(
                                        height: 153, // Match parent height
                                        child: Center(
                                          child: Icon(
                                              Icons.error_outline_outlined,
                                              size: 20),
                                        ),
                                      ),
                              ), // Image.asset(
                              //   'assets/images/gra.png', // Change to your image asset
                              //   width: double.infinity,
                              //   height: 153, // 80% of container height
                              //   fit: BoxFit.contain,
                              // ),
                              // Bottom row with text and price
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller
                                          .childrenList
                                          .first
                                          .selectedMealMenuData!
                                          .first
                                          .mealName!,
                                      style: AppTextStyles.MetropolisMedium
                                          .copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '\$${controller.childrenList.first.selectedMealMenuData!.first.mealPrice}',
                                      style: AppTextStyles.MetropolisMedium
                                          .copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ListView of WalletBalanceCards
                  // ignore: prefer_const_constructors
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: controller
                                                .childrenList
                                                .first
                                                .selectedMealMenuData!
                                                .first
                                                .imageUrl !=
                                            null &&
                                        controller
                                            .childrenList
                                            .first
                                            .selectedMealMenuData!
                                            .first
                                            .imageUrl!
                                            .isNotEmpty
                                    ? Image.network(
                                        controller
                                            .childrenList
                                            .first
                                            .selectedMealMenuData!
                                            .first
                                            .imageUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.error_outline);
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/profile_emoji.png',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.childrenList.first.childName ??
                                        "N/A",
                                    style:
                                        AppTextStyles.MetropolisMedium.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                controller.childrenList.first.schoolName ??
                                    "N/A",
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF858585),
                                ),
                              ),
                              Text(
                                controller.childrenList.first.childSchoolID ??
                                    "N/A",
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF858585),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  //   child: const WalletBalanceCard(
                  //     isEdit: false,
                  //     walletDesc: 'Wallet Remaining Balance',
                  //     price: '\$250',
                  //     isShowScan: true,
                  //     isNoImage: true,
                  //     isPreparing: false,
                  //     isDelivered: false,
                  //     isStaff: false,
                  //     isType: false,
                  //     isDuration: false,
                  //   ),
                  // ),

                  const SizedBox(
                    height: 20,
                  ),

                  Obx(
                    () => CustomButton1(
                        text: 'START PREPARATION',
                        onPressed: () async {
                          final parentId =
                              controller.childrenList.first.parentId;
                          if (parentId != null) {
                            print("parent id is $parentId");

                            await controller.fetchChildParentWallet(parentId);
                          } else {
                            Get.snackbar('Error', 'Child ID not found');
                          }
                        },
                        isLoading: controller.isLoading.value),
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
