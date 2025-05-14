import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import '../controllers/new_order_details_controller.dart';

class NewOrderDetailsView extends GetView<NewOrderDetailsController> {
  const NewOrderDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<NewOrderDetailsController>(
          id: 'newOrderDetailsId',
          builder: (controller) {
            return Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.orderData.value == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gradientStartColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Go Back',
                            style: AppTextStyles.MetropolisMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.orderData.value == null) {
                return const Center(child: Text('No order data available'));
              }

              // Format order date
              String orderDate = 'Unknown date';
              if (controller.orderData.value!.date != null &&
                  controller.orderData.value!.date!.isNotEmpty) {
                try {
                  DateTime date =
                      DateTime.parse(controller.orderData.value!.date!);
                  orderDate = DateFormat('MMMM d, yyyy').format(date);
                } catch (e) {
                  print("Error parsing date: $e");
                }
              }

              return Column(
                children: [
                  // Header with back button
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.gradientStartColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                'New Order Details',
                                style: AppTextStyles.MetropolisBold.copyWith(
                                  fontSize: 18,
                                  color: const Color(0xFF434343),
                                ),
                              ),
                            ),

                            // Order date
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              child: Text(
                                'Order date: $orderDate',
                                style: AppTextStyles.MetropolisMedium.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),

                            // Parent information
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order By',
                                    style:
                                        AppTextStyles.MetropolisBold.copyWith(
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
                                              color:
                                                  AppColors.gradientStartColor,
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
                                                controller.parentName.value,
                                                style: AppTextStyles
                                                    .MetropolisBold.copyWith(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Parent',
                                                style: AppTextStyles
                                                    .MetropolisRegular.copyWith(
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

                            const SizedBox(height: 24),

                            // Student information
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Information',
                                    style:
                                        AppTextStyles.MetropolisBold.copyWith(
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
                                        // Student photo
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            shape: BoxShape.circle,
                                          ),
                                          child: (controller.hasOrderId.value &&
                                                      controller
                                                              .orderData
                                                              .value!
                                                              .childImageUrl !=
                                                          null &&
                                                      controller
                                                          .orderData
                                                          .value!
                                                          .childImageUrl!
                                                          .isNotEmpty) ||
                                                  (!controller
                                                          .hasOrderId.value &&
                                                      controller.childImageUrl
                                                          .value.isNotEmpty)
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.network(
                                                    controller.hasOrderId.value
                                                        ? controller
                                                            .orderData
                                                            .value!
                                                            .childImageUrl!
                                                        : controller
                                                            .childImageUrl
                                                            .value,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                        Icons.person,
                                                        color: Colors.grey,
                                                        size: 30,
                                                      );
                                                    },
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 30,
                                                ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller.hasOrderId.value
                                                    ? (controller.orderData
                                                            .value!.childName ??
                                                        'Student')
                                                    : (controller.childName
                                                            .value.isNotEmpty
                                                        ? controller
                                                            .childName.value
                                                        : 'Student'),
                                                style: AppTextStyles
                                                    .MetropolisBold.copyWith(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (controller.hasOrderId.value &&
                                                  controller.orderData.value!
                                                          .childSchoolID !=
                                                      null)
                                                Text(
                                                  'ID: ${controller.orderData.value!.childSchoolID}',
                                                  style: AppTextStyles
                                                          .MetropolisRegular
                                                      .copyWith(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              if (controller.hasOrderId.value &&
                                                  controller.orderData.value!
                                                          .schoolName !=
                                                      null)
                                                Text(
                                                  controller.orderData.value!
                                                      .schoolName!,
                                                  style: AppTextStyles
                                                          .MetropolisRegular
                                                      .copyWith(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              if (!controller
                                                      .hasOrderId.value &&
                                                  controller.schoolName.value
                                                      .isNotEmpty)
                                                Text(
                                                  controller.schoolName.value,
                                                  style: AppTextStyles
                                                          .MetropolisRegular
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

                            const SizedBox(height: 24),

                            // Show message when no order ID is available
                            if (!controller.hasOrderId.value)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.amber, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.amber,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Order details not available',
                                        style: AppTextStyles.MetropolisBold
                                            .copyWith(
                                          fontSize: 16,
                                          color: Colors.amber[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'This is a new order notification. The order ID is not available yet. You can view more details in the orders section once the order is processed.',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.MetropolisRegular
                                            .copyWith(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Meal details
                            if (controller.hasOrderId.value &&
                                controller.orderData.value!
                                        .selectedMealMenuData !=
                                    null &&
                                controller.orderData.value!
                                    .selectedMealMenuData!.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Meal Details',
                                      style:
                                          AppTextStyles.MetropolisBold.copyWith(
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
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(12)),
                                            child: controller
                                                            .orderData
                                                            .value!
                                                            .selectedMealMenuData![
                                                                0]
                                                            .imageUrl !=
                                                        null &&
                                                    controller
                                                        .orderData
                                                        .value!
                                                        .selectedMealMenuData![
                                                            0]
                                                        .imageUrl!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    controller
                                                        .orderData
                                                        .value!
                                                        .selectedMealMenuData![
                                                            0]
                                                        .imageUrl!,
                                                    width: double.infinity,
                                                    height: 180,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
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
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        height: 180,
                                                        color: Colors.grey[200],
                                                        child: const Center(
                                                          child: Icon(
                                                              Icons
                                                                  .error_outline,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    height: 180,
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                          Icons.fastfood,
                                                          size: 40,
                                                          color: Colors.grey),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        controller
                                                                .orderData
                                                                .value!
                                                                .selectedMealMenuData![
                                                                    0]
                                                                .mealName ??
                                                            'Meal',
                                                        style: AppTextStyles
                                                                .MetropolisBold
                                                            .copyWith(
                                                          fontSize: 18,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      '\$${controller.orderData.value!.selectedMealMenuData![0].mealPrice ?? '0.00'}',
                                                      style: AppTextStyles
                                                              .MetropolisBold
                                                          .copyWith(
                                                        fontSize: 18,
                                                        color: AppColors
                                                            .gradientStartColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                if (controller
                                                            .orderData
                                                            .value!
                                                            .selectedMealMenuData![
                                                                0]
                                                            .schedule !=
                                                        null &&
                                                    controller
                                                            .orderData
                                                            .value!
                                                            .selectedMealMenuData![
                                                                0]
                                                            .schedule!
                                                            .availableAt !=
                                                        null &&
                                                    controller
                                                        .orderData
                                                        .value!
                                                        .selectedMealMenuData![
                                                            0]
                                                        .schedule!
                                                        .availableAt!
                                                        .isNotEmpty)
                                                  Text(
                                                    'Time: ${controller.orderData.value!.selectedMealMenuData![0].schedule!.availableAt![0]}',
                                                    style: AppTextStyles
                                                            .MetropolisRegular
                                                        .copyWith(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                if (controller
                                                        .orderData
                                                        .value!
                                                        .selectedMealMenuData![
                                                            0]
                                                        .scheduleStatement !=
                                                    null)
                                                  Text(
                                                    controller
                                                        .orderData
                                                        .value!
                                                        .selectedMealMenuData![
                                                            0]
                                                        .scheduleStatement!,
                                                    style: AppTextStyles
                                                            .MetropolisRegular
                                                        .copyWith(
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

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}
