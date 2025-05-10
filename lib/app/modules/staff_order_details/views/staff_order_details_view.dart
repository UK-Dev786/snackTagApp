import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/config/app_colors.dart';
import '../controllers/staff_order_details_controller.dart';

class StaffOrderDetailsView extends GetView<StaffOrderDetailsController> {
  const StaffOrderDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<StaffOrderDetailsController>(
          init: StaffOrderDetailsController(),
          builder: (controller) {
            return Column(
              children: [
                // Header with back button
                // Padding(
                //   padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                //   child: Row(
                //     children: [
                //       GestureDetector(
                //         onTap: () => Get.back(),
                //         child: Container(
                //           padding: const EdgeInsets.all(8),
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(8),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.grey.withOpacity(0.3),
                //                 spreadRadius: 1,
                //                 blurRadius: 3,
                //                 offset: const Offset(0, 1),
                //               ),
                //             ],
                //           ),
                //           child: const Icon(
                //             Icons.arrow_back_ios_new,
                //             size: 16,
                //             color: Colors.black,
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 16),
                //       Text(
                //         "Order Details",
                //         style: AppTextStyles.MetropolisBold.copyWith(
                //           fontSize: 18,
                //           color: Colors.black,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 20),

                // Grid with time slots and food items
                Expanded(
                  child: Column(
                    children: [
                      // Snack bag icon
                      Image.asset(
                        AppImages.authImg,
                        width: 83,
                        height: 95,
                      ),

                      // Time slots and food items
                      Expanded(
                        child: Obx(() {
                          return ListView.builder(
                            itemCount: controller.timeSlots.length,
                            itemBuilder: (context, index) {
                              final timeSlot = controller.timeSlots[index];
                              final isSelected =
                                  controller.selectedTimeSlot.value == timeSlot;

                              if (!isSelected) return const SizedBox.shrink();

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Time slot
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 40),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCFF00),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        timeSlot,
                                        textAlign: TextAlign.left,
                                        style: AppTextStyles.MetropolisBold
                                            .copyWith(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Food items
                                  ...controller.foodItemsData.value![timeSlot]!
                                      .map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          right: 40, left: 120),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['name'] ?? '',
                                            style: AppTextStyles
                                                .MetropolisMedium.copyWith(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 21,
                                          ),
                                          Text(
                                            item['calories'] ?? '',
                                            style: AppTextStyles.MetropolisThin
                                                .copyWith(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 25.0, left: 25.0),
                                    child: Divider(),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                      ),

                      // Navigation buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous button
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.goToPreviousTimeSlot,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              AppImages.baseButton))),
                                  child: Center(
                                    child: Text(
                                      "PREVIOUS",
                                      style:
                                          AppTextStyles.MetropolisBold.copyWith(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Next button
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.goToNextTimeSlot,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              AppImages.baseButton))),
                                  child: Center(
                                    child: Text(
                                      "NEXT",
                                      style:
                                          AppTextStyles.MetropolisBold.copyWith(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Back to calendar button
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: GestureDetector(
                          onTap: controller.goBackToCalendar,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(AppImages.baseButton))),
                            child: Center(
                              child: Text(
                                "BACK TO CALENDAR",
                                style: AppTextStyles.MetropolisBold.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
