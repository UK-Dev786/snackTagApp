import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/config/appBuilderId.dart';
import '../controllers/cafe_owner_order_delivery_details_controller.dart';

class CafeOwnerOrderDeliveryDetailsView extends StatelessWidget {
  const CafeOwnerOrderDeliveryDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: GetBuilder<CafeOwnerOrderDeliveryDetailsController>(
            init: CafeOwnerOrderDeliveryDetailsController(),
            id: cafeOwnerOrderDeliveryDetailsId,
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

                if (controller.deliveredOrderData.value == null) {
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

                // Format delivery time
                String deliveryTime = "N/A";
                if (controller.deliveredOrderData.value!.orderDeliveredTime !=
                        null &&
                    controller.deliveredOrderData.value!.orderDeliveredTime!
                        .isNotEmpty) {
                  try {
                    DateTime parsedTime = DateTime.parse(controller
                        .deliveredOrderData.value!.orderDeliveredTime!);
                    deliveryTime =
                        DateFormat('MMM d, yyyy - h:mm a').format(parsedTime);
                  } catch (e) {
                    print("Error parsing delivery time: $e");
                  }
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
                      ),
                    ),

                    // Title
                    Center(
                      child: Text(
                        'Order Delivery Details',
                        style: AppTextStyles.MetropolisBold.copyWith(
                          fontSize: 18,
                          color: const Color(0xFF434343),
                        ),
                      ),
                    ),

                    // Delivery time
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Text(
                        'Delivered on: $deliveryTime',
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
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: controller.deliveredOrderData.value!
                                              .childImageUrl !=
                                          null &&
                                      controller.deliveredOrderData.value!
                                          .childImageUrl!.isNotEmpty
                                  ? Image.network(
                                      controller.deliveredOrderData.value!
                                          .childImageUrl!,
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
                            controller.deliveredOrderData.value!.childName ??
                                'Student',
                            style: AppTextStyles.MetropolisMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            controller.deliveredOrderData.value!.schoolName ??
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
                    if (controller.deliveredOrderData.value!
                                .selectedMealMenuData !=
                            null &&
                        controller.deliveredOrderData.value!
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
                                    color: Colors.grey.withOpacity(0.3),
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
                                                    .deliveredOrderData
                                                    .value!
                                                    .selectedMealMenuData![0]
                                                    .imageUrl !=
                                                null &&
                                            controller
                                                .deliveredOrderData
                                                .value!
                                                .selectedMealMenuData![0]
                                                .imageUrl!
                                                .isNotEmpty
                                        ? Image.network(
                                            controller
                                                .deliveredOrderData
                                                .value!
                                                .selectedMealMenuData![0]
                                                .imageUrl!,
                                            width: double.infinity,
                                            height: 180,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
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
                                                        .deliveredOrderData
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
                                                "MX\$${controller.deliveredOrderData.value!.selectedMealMenuData![0].mealPrice}" ??
                                                    '\$0.00',
                                                style: AppTextStyles
                                                    .MetropolisBold.copyWith(
                                                  fontSize: 16,
                                                  color: AppColors
                                                      .gradientStartColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (controller
                                                    .deliveredOrderData
                                                    .value!
                                                    .selectedMealMenuData![0]
                                                    .schedule
                                                    ?.availableAt !=
                                                null &&
                                            controller
                                                .deliveredOrderData
                                                .value!
                                                .selectedMealMenuData![0]
                                                .schedule!
                                                .availableAt!
                                                .isNotEmpty)
                                          Text(
                                            'Time: ${controller.deliveredOrderData.value!.selectedMealMenuData![0].schedule!.availableAt![0]}',
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
                            'Delivered By',
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
                                  color: Colors.grey.withOpacity(0.3),
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
                                        .withOpacity(0.1),
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
                                        controller.deliveredOrderData.value!
                                                .orderDeliveredBy ??
                                            'Staff',
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
