import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_history/controllers/staff_history_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/appBuilderId.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_wallet_widget.dart';
import 'package:intl/intl.dart';

import '../controllers/staff_preparing_controller.dart';

class StaffPreparingView extends GetView<StaffOrderPreparingController> {
  const StaffPreparingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<StaffOrderPreparingController>(
          init: StaffOrderPreparingController(),
          id: staffOrderPreparingId,
          builder: (controller) {
            return Column(
              children: [
                // Row with month/year and calendar icon
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: DateFormat('MMMM ')
                                      .format(DateTime.now()),
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
                        ],
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     historyController.updateSelectedIndex(1);
                      //   },
                      //   child: Image.asset(
                      //     'assets/icon/calendar.png',
                      //     height: 20,
                      //     width: 20,
                      //   ),
                      // )
                    ],
                  ),
                ),

                // ListView of WalletBalanceCards
                Expanded(
                    child: controller.preparingOrdersList.isNotEmpty
                        ? ListView.separated(
                            itemCount: controller.preparingOrdersList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8), // Display 4 items
                            padding: const EdgeInsets.only(
                                top: 8), // Reduce the top padding
                            itemBuilder: (context, index) {
                              final preparingOrder =
                                  controller.preparingOrdersList[index];
//                       final child = preparingOrder.childName;

                              return Container(
                                height: 117,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(
                                          0, 6), // changes position of shadow
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Row(
                                  children: [
                                    // Profile image wrapped with Container
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start, // Align image to top
                                      children: [,kj;;
                                        Container(
                                          width: 55,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 6,
                                                offset: const Offset(
                                                    0, 3), // shadow position
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: controller
                                                            .preparingOrdersList[
                                                                index]
                                                            .childImageUrl !=
                                                        null &&
                                                    controller
                                                        .preparingOrdersList[
                                                            index]
                                                        .childImageUrl!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    controller
                                                        .preparingOrdersList[
                                                            index]
                                                        .childImageUrl!,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons
                                                              .error_outline_rounded,
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
                                      ],
                                    ),
                                    const SizedBox(width: 12),

                                    // Details Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                preparingOrder.childName ?? "",
                                                style: AppTextStyles
                                                    .MetropolisMedium.copyWith(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Spacer(),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                          Text(
                                            preparingOrder.schoolName ?? "",
                                            style:
                                                AppTextStyles.MetropolisRegular
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xFF858585)),
                                          ),
                                          Text(
                                            preparingOrder.childSchoolID ?? "",
                                            style:
                                                AppTextStyles.MetropolisRegular
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xFF858585)),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GradientButton(
                                              height: 30,
                                              width: 90,
                                              onTap: () {
                                                // print("Preparing button tapped!${controller.preparingOrdersList[index].orderPreparedBy!}");
                                                controller.markAsDelivered(
                                                    controller
                                                        .preparingOrdersList[
                                                            index]
                                                        .orderPrepId!,
                                                    controller
                                                        .preparingOrdersList[
                                                            index]
                                                        .orderPreparedBy!);
                                                print(
                                                    "Preparing button tapped!");
                                                // Add your onTap logic here
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      width: 1,
                                      color: Colors.black.withOpacity(0.1),
                                      margin: const EdgeInsets.only(
                                          left: 6, right: 10),
                                    ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(height: 8),

                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 6,
                                                offset: const Offset(
                                                    0, 3), // shadow position
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: controller
                                                            .preparingOrdersList[
                                                                index]
                                                            .selectedMealMenuData![
                                                                0]
                                                            .imageUrl !=
                                                        null &&
                                                    controller
                                                        .preparingOrdersList[
                                                            index]
                                                        .selectedMealMenuData![
                                                            0]
                                                        .imageUrl!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    controller
                                                        .preparingOrdersList[
                                                            index]
                                                        .selectedMealMenuData![
                                                            0]
                                                        .imageUrl!,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons
                                                              .error_outline_rounded,
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
                                          style: AppTextStyles.MetropolisMedium
                                              .copyWith(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
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
                                  'No Orders in Preparing',
                                  style: AppTextStyles.PoppinsBold.copyWith(
                                    fontSize: 16,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'There are currently no orders being in Preparing',
                                  style: AppTextStyles.PoppinsRegular.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )),
              ],
            );
          }),
    );
  }
}
