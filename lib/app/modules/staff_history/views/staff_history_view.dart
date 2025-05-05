import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_history_detail/views/staff_history_detail_view.dart';
import 'package:snacktag/app/modules/staff_history_list/views/staff_history_list_view.dart';
import 'package:snacktag/app/modules/staff_preparing/views/staff_preparing_view.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

import '../controllers/staff_history_controller.dart';

class StaffHistoryView extends GetView<StaffHistoryController> {
  const StaffHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () {
              // If selectedIndex is 2, return an empty container to hide the tabs
              if (controller.selectedIndex.value == 2) {
                return Container(); // This will hide the entire Row
              }

              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 86),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Preparing Tab
                    GestureDetector(
                      onTap: () => controller.updateSelectedIndex(0),
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: controller.selectedIndex.value == 0
                              ? const LinearGradient(
                                  colors: [AppColors.gradientStartColor, AppColors.gradientEndColor],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: controller.selectedIndex.value == 0
                              ? null
                              : const Color(0xFFF5F5F5),
                        ),
                        child: Center(
                          child: Text(
                            'Preparing',
                            style: controller.selectedIndex.value == 0
                                ? AppTextStyles.MetropolisBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  )
                                : AppTextStyles.MetropolisRegular.copyWith(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // History Tab
                    GestureDetector(
                      onTap: () => controller.updateSelectedIndex(1),
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: controller.selectedIndex.value == 1
                              ? const LinearGradient(
                                  colors: [AppColors.gradientStartColor, AppColors.gradientEndColor],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: controller.selectedIndex.value == 1
                              ? null
                              : const Color(0xFFF5F5F5),
                        ),
                        child: Center(
                          child: Text(
                            'History',
                            style: controller.selectedIndex.value == 1
                                ? AppTextStyles.MetropolisBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  )
                                : AppTextStyles.MetropolisRegular.copyWith(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Content for tabs
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.selectedIndex.value,
                children: const [
                  StaffPreparingView(),
                  StaffHistoryListView(),
                  StaffHistoryDetailView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
