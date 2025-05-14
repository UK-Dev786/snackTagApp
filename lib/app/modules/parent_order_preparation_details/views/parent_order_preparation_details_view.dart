import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import '../controllers/parent_order_preparation_details_controller.dart';

class ParentOrderPreparationDetailsView extends StatelessWidget {
  const ParentOrderPreparationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: GetBuilder<ParentOrderPreparationDetailsController>(
            init: ParentOrderPreparationDetailsController(),
            id: parentOrderPreparationDetailsId,
            builder: (controller) {
              return Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: CircularProgressIndicator(
                        color: AppColors.gradientEndColor,
                      ),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Column(
                        children: [
                          Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.MetropolisRegular.copyWith(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.preparedOrderData.value == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Column(
                        children: [
                          Text(
                            'No order data available',
                            style: AppTextStyles.MetropolisRegular.copyWith(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 35,
                            width: 35,
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(51), // 0.2 opacity
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
                      ),
                    ),

                    // Title
                    Center(
                      child: Text(
                        'Order Preparation Details',
                        style: AppTextStyles.MetropolisBold.copyWith(
                          fontSize: 18,
                          color: const Color(0xFF434343),
                        ),
                      ),
                    ),

                    // Preparation time
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Text(
                        controller.getPreparationTimeString(),
                        style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    // Student photo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 125,
                            height: 125,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(77), // 0.3 opacity
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: controller.preparedOrderData.value!
                                              .childImageUrl !=
                                          null &&
                                      controller.preparedOrderData.value!
                                          .childImageUrl!.isNotEmpty
                                  ? Image.network(
                                      controller.preparedOrderData.value!
                                          .childImageUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                            Icons.error_outline_rounded,
                                            size: 20);
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/profile_emoji.png',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.preparedOrderData.value!.childName ??
                                'Student',
                            style: AppTextStyles.MetropolisMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            controller.preparedOrderData.value!.schoolName ??
                                'School',
                            style: AppTextStyles.MetropolisRegular.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Meal details
                    if (controller.preparedOrderData.value!
                                .selectedMealMenuData !=
                            null &&
                        controller.preparedOrderData.value!
                            .selectedMealMenuData!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meal Details',
                              style: AppTextStyles.MetropolisBold.copyWith(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withAlpha(77), // 0.3 opacity
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Meal image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: controller
                                                    .preparedOrderData
                                                    .value!
                                                    .selectedMealMenuData![0]
                                                    .imageUrl !=
                                                null &&
                                            controller
                                                .preparedOrderData
                                                .value!
                                                .selectedMealMenuData![0]
                                                .imageUrl!
                                                .isNotEmpty
                                        ? Image.network(
                                            controller
                                                .preparedOrderData
                                                .value!
                                                .selectedMealMenuData![0]
                                                .imageUrl!,
                                            width: double.infinity,
                                            height: 180,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return SizedBox(
                                                height: 180,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.error_outline,
                                                      size: 40,
                                                      color: Colors.grey),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 180,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Icon(Icons.fastfood,
                                                  size: 40, color: Colors.grey),
                                            ),
                                          ),
                                  ),

                                  // Meal details
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                controller
                                                        .preparedOrderData
                                                        .value!
                                                        .selectedMealMenuData![
                                                            0]
                                                        .mealName ??
                                                    'Meal',
                                                style: AppTextStyles
                                                    .MetropolisBold.copyWith(
                                                  fontSize: 18,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.baseColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                controller.preparedOrderData.value!.selectedMealMenuData![0].mealPrice != null
                                                    ? "MX\$${controller.preparedOrderData.value!.selectedMealMenuData![0].mealPrice}"
                                                    : '\$0.00',
                                                style: AppTextStyles
                                                    .MetropolisBold.copyWith(
                                                  fontSize: 16,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (controller
                                                    .preparedOrderData
                                                    .value!
                                                    .selectedMealMenuData![0]
                                                    .schedule
                                                    ?.availableAt !=
                                                null &&
                                            controller
                                                .preparedOrderData
                                                .value!
                                                .selectedMealMenuData![0]
                                                .schedule!
                                                .availableAt!
                                                .isNotEmpty)
                                          Text(
                                            'Time: ${controller.preparedOrderData.value!.selectedMealMenuData![0].schedule!.availableAt![0]}',
                                            style: AppTextStyles
                                                .MetropolisRegular.copyWith(
                                              fontSize: 14,
                                              color: Colors.grey[700],
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

                    const SizedBox(height: 24),

                    // Staff details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prepared By',
                            style: AppTextStyles.MetropolisBold.copyWith(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(77), // 0.3 opacity
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.gradientStartColor
                                        .withAlpha(26), // 0.1 opacity
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.gradientStartColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.getStaffName(),
                                        style: AppTextStyles.MetropolisBold
                                            .copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Staff',
                                        style: AppTextStyles.MetropolisRegular
                                            .copyWith(
                                          fontSize: 14,
                                          color: Colors.grey[600],
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

                    const SizedBox(height: 30),
                  ],
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
