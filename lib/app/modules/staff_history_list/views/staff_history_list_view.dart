import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/appBuilderId.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/parents_models/add_children.dart';


import '../controllers/staff_history_list_controller.dart';

class StaffHistoryListView extends GetView<StaffHistoryListController> {
  const StaffHistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    // final historyController = Get.find<StaffHistoryController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<StaffHistoryListController>(
          init: StaffHistoryListController(),
          id: staffOrderDeliveredId,
          builder: (controller) {
            return Column(
              children: [
                // ListView of WalletBalanceCards
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gradientEndColor,
                        ),
                      );
                    }

                    return controller.deliveredOrdersList.isNotEmpty
                        ? ListView.builder(
                            itemCount: controller.deliveredOrdersList.length,
                            padding: const EdgeInsets.only(top: 8),
                            itemBuilder: (context, index) {
                              final preparingOrder = controller.deliveredOrdersList[index];
                            
                              return GestureDetector(
                                onTap: () {
                                   Get.toNamed(
                                Routes.STAFF_DELIVERED_ORDER_HISTORY_DETAILS,
                                arguments: {
                                  "DeliveredOrderData": controller.deliveredOrdersList[index],
                                },
                              );
                                },
                                child: Container(
                                  height: 117,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Row(
                                    children: [
                                      // Profile image
                                      _buildProfileImage(preparingOrder),
                                      const SizedBox(width: 12),
                                
                                      // Details
                                      Expanded(
                                        child: _buildDetailsColumn(preparingOrder, controller),
                                      ),
                                
                                      // Divider
                                      Container(
                                        width: 1,
                                        color: Colors.black.withOpacity(0.1),
                                        margin: const EdgeInsets.only(left: 6, right: 10),
                                      ),
                                
                                      // Meal image
                                      _buildMealImage(preparingOrder),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  'No Orders in Delivered',
                                  style: AppTextStyles.PoppinsBold.copyWith(
                                    fontSize: 16,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'There are currently no orders being Delivered',
                                  style: AppTextStyles.PoppinsRegular.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                    
                  }),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildProfileImage(ParentsAddChildren preparingOrder) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 55,
          height: 55,
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
            child: preparingOrder.childImageUrl != null && preparingOrder.childImageUrl!.isNotEmpty
                ? Image.network(
                    preparingOrder.childImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error_outline_rounded, size: 20);
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
    );
  }

  Widget _buildDetailsColumn(ParentsAddChildren preparingOrder, StaffHistoryListController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              preparingOrder.childName ?? "",
              style: AppTextStyles.MetropolisMedium.copyWith(
                fontSize: 14,
              ),
            ),
            const Spacer(),
          ],
        ),
        Text(
          preparingOrder.schoolName ?? "",
          style: AppTextStyles.MetropolisRegular.copyWith(
            fontSize: 12,
            color: const Color(0xFF858585),
          ),
        ),
        Text(
          preparingOrder.childSchoolID ?? "",
          style: AppTextStyles.MetropolisRegular.copyWith(
            fontSize: 12,
            color: const Color(0xFF858585),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            preparingOrder.status ?? "Delivered",
            style: AppTextStyles.MetropolisMedium.copyWith(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealImage(ParentsAddChildren preparingOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 8),

        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3), // shadow position
              ),
            ],
          ),
          child: ClipOval(
            child: preparingOrder.selectedMealMenuData![0].imageUrl != null &&
                    preparingOrder.selectedMealMenuData![0].imageUrl!.isNotEmpty
                ? Image.network(
                    preparingOrder.selectedMealMenuData![0].imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error_outline_rounded, size: 20);
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
        // Divider
        Container(
          width: 40, // Adjust as needed
          height: 1,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 4),
        Text(
          "\$${preparingOrder.selectedMealMenuData![0].mealPrice.toString()}",
          style: AppTextStyles.MetropolisMedium.copyWith(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
