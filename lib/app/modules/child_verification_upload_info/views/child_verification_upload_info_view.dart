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
    // Get today's day of week
    final now = DateTime.now();
    final currentDayName = DateFormat('EEEE').format(now);
    final currentDayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.

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

                  // Auth Image at the top
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.asset(
                        'assets/images/authImg.png', // Use the auth image
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),

                  // Remove the "UPLOAD INFO" title
                  const SizedBox(height: 32),

                  // Child info row with image and name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 0),
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(12),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.grey.withOpacity(0.2),
                      //       spreadRadius: 1,
                      //       blurRadius: 4,
                      //       offset: const Offset(0, 2),
                      //     ),
                      //   ],
                      // ),
                      child: Row(
                        children: [
                          // Child image (left)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: controller.childrenList.first
                                              .childImageUrl !=
                                          null &&
                                      controller.childrenList.first
                                          .childImageUrl!.isNotEmpty
                                  ? Image.network(
                                      controller
                                          .childrenList.first.childImageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        final gender = controller
                                                .childrenList.first.childGender
                                                ?.toLowerCase() ??
                                            '';
                                        return Image.asset(
                                          gender == 'female'
                                              ? 'assets/images/femaleAvatar.png'
                                              : 'assets/images/maleAatar.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : controller.childrenList.isNotEmpty &&
                                          controller.childrenList.first
                                                  .childGender !=
                                              null
                                      ? Image.asset(
                                          controller.childrenList.first
                                                      .childGender!
                                                      .toLowerCase() ==
                                                  'female'
                                              ? 'assets/images/femaleAvatar.png'
                                              : 'assets/images/maleAvatar.png',
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/profile_emoji.png',
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.childrenList.first.childName ??
                                      "Student",
                                  style:
                                      AppTextStyles.MetropolisMedium.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xFF434343),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.childrenList.first.childSchoolID ??
                                      "ID: N/A",
                                  style:
                                      AppTextStyles.MetropolisRegular.copyWith(
                                    fontSize: 14,
                                    color: const Color(0xFF858585),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Today's meals section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Today\'s Meals',
                            style: AppTextStyles.MetropolisMedium.copyWith(
                              fontSize: 16,
                              color: const Color(0xFF434343),
                            ),
                          ),
                        ),

                        // List of today's meals
                        Builder(
                          builder: (context) {
                            // Filter meals for today
                            final todayMeals = controller
                                        .childrenList.isNotEmpty &&
                                    controller.childrenList.first
                                            .selectedMealMenuData !=
                                        null
                                ? controller
                                    .childrenList.first.selectedMealMenuData!
                                    .where((meal) {
                                    // Skip meals with no schedule or scheduled dates
                                    if (meal.scheduledDates == null ||
                                        meal.scheduledDates!.isEmpty) {
                                      return false;
                                    }

                                    // Format today's date in the same format as scheduledDates (dd-MM-yyyy)
                                    final today = DateTime.now();
                                    final formattedToday =
                                        DateFormat('dd-MM-yyyy').format(today);

                                    // Check if today's date exists in the scheduledDates list
                                    bool isTodayScheduled = meal.scheduledDates!
                                        .contains(formattedToday);

                                    if (isTodayScheduled) {
                                      print(
                                          "Meal ${meal.mealName} is scheduled for today ($formattedToday)");
                                    }

                                    return isTodayScheduled;
                                  }).toList()
                                : [];

                            if (todayMeals.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.calendar_today_outlined,
                                          size: 40, color: Colors.grey[500]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No meals scheduled for today',
                                        style: AppTextStyles.MetropolisRegular
                                            .copyWith(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: todayMeals.length,
                              itemBuilder: (context, index) {
                                final meal = todayMeals[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  // decoration: BoxDecoration(
                                  //   color: Colors.white,
                                  //   borderRadius: BorderRadius.circular(12),
                                  //   boxShadow: [
                                  //     BoxShadow(
                                  //       color: Colors.grey.withOpacity(0.2),
                                  //       spreadRadius: 1,
                                  //       blurRadius: 4,
                                  //       offset: const Offset(0, 2),
                                  //     ),
                                  //   ],
                                  // ),
                                  child: Row(
                                    children: [
                                      // Meal image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        child: meal.imageUrl != null &&
                                                meal.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                meal.imageUrl!,
                                                width: 60,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return const SizedBox(
                                                    width: 100,
                                                    height: 100,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: 60,
                                                    height: 50,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                width: 60,
                                                height: 50,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),

                                      // Meal details
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      meal.mealName ??
                                                          'Unnamed Meal',
                                                      style: AppTextStyles
                                                              .MetropolisMedium
                                                          .copyWith(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  // Status indicator
                                                  Obx(() {
                                                    final status = controller
                                                        .getMealStatus(meal);
                                                    Color statusColor;
                                                    IconData statusIcon;

                                                    switch (status) {
                                                      case 'Delivered':
                                                        statusColor =
                                                            Colors.green;
                                                        statusIcon =
                                                            Icons.check_circle;
                                                        break;
                                                      case 'In Preparation':
                                                        statusColor =
                                                            Colors.orange;
                                                        statusIcon =
                                                            Icons.restaurant;
                                                        break;
                                                      default:
                                                        statusColor =
                                                            Colors.blue;
                                                        statusIcon =
                                                            Icons.schedule;
                                                    }

                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: statusColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            statusIcon,
                                                            size: 12,
                                                            color: statusColor,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            status,
                                                            style: AppTextStyles
                                                                    .MetropolisRegular
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color:
                                                                  statusColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                              // const SizedBox(height: 4),
                                              // Display meal time if available
                                              if (meal.schedule != null &&
                                                  meal.schedule!.availableAt !=
                                                      null &&
                                                  meal.schedule!.availableAt!
                                                      .isNotEmpty)
                                                Text(
                                                  'Time: ${meal.schedule!.availableAt!.join(", ")}',
                                                  style: AppTextStyles
                                                          .MetropolisMedium
                                                      .copyWith(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),

                                              // Add preparation button
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Obx(() {
                                                  final status = controller
                                                      .getMealStatus(meal);

                                                  // If meal is already delivered or in preparation, don't show the button
                                                  if (status == 'Delivered' ||
                                                      status ==
                                                          'In Preparation') {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  return GestureDetector(
                                                    onTap: () async {
                                                      // Check if current time is within the allowed preparation window
                                                      bool isWithinTimeWindow =
                                                          false;
                                                      String timeMessage = "";

                                                      if (meal.schedule !=
                                                              null &&
                                                          meal.schedule!
                                                                  .availableAt !=
                                                              null &&
                                                          meal
                                                              .schedule!
                                                              .availableAt!
                                                              .isNotEmpty) {
                                                        final now =
                                                            DateTime.now();
                                                        final currentHour =
                                                            now.hour;

                                                        // Check each available time
                                                        for (String timeStr
                                                            in meal.schedule!
                                                                .availableAt!) {
                                                          int scheduledHour = 0;

                                                          // Parse the time string (e.g., "9am", "2pm")
                                                          if (timeStr
                                                              .contains('am')) {
                                                            scheduledHour = int
                                                                .parse(timeStr
                                                                    .replaceAll(
                                                                        'am',
                                                                        ''));
                                                            // Handle 12am as 0 hour
                                                            if (scheduledHour ==
                                                                12)
                                                              scheduledHour = 0;
                                                          } else if (timeStr
                                                              .contains('pm')) {
                                                            scheduledHour = int
                                                                .parse(timeStr
                                                                    .replaceAll(
                                                                        'pm',
                                                                        ''));
                                                            // Add 12 for PM times, except 12pm
                                                            if (scheduledHour !=
                                                                12)
                                                              scheduledHour +=
                                                                  12;
                                                          }
                                                          // todo change it to 1 hour
                                                          // Check if current time is within ±1 hour window
                                                          if (currentHour >=
                                                                  scheduledHour -
                                                                      24 &&
                                                              currentHour <=
                                                                  scheduledHour +
                                                                      24) {
                                                            isWithinTimeWindow =
                                                                true;
                                                            break;
                                                          }
                                                        }

                                                        if (!isWithinTimeWindow) {
                                                          timeMessage =
                                                              "This meal can only be prepared within 1 hour of its scheduled time.";
                                                        }
                                                      } else {
                                                        // If no schedule is defined, allow preparation at any time
                                                        isWithinTimeWindow =
                                                            true;
                                                      }

                                                      if (isWithinTimeWindow) {
                                                        final parentId =
                                                            controller
                                                                .childrenList
                                                                .first
                                                                .parentId;
                                                        if (parentId != null) {
                                                          await controller
                                                              .fetchChildParentWallet(
                                                                  parentId,
                                                                  meal);
                                                        } else {
                                                          Get.snackbar('Error',
                                                              'Parent ID not found');
                                                        }
                                                      } else {
                                                        Get.snackbar(
                                                          'Outside Preparation Window',
                                                          timeMessage,
                                                          backgroundColor:
                                                              Colors.orange,
                                                          colorText:
                                                              Colors.white,
                                                          duration:
                                                              const Duration(
                                                                  seconds: 3),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color(0xFFFC6011),
                                                            Color(0xFFFF8D41)
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Text(
                                                        'Start Preparation',
                                                        style: AppTextStyles
                                                                .MetropolisRegular
                                                            .copyWith(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ListView of WalletBalanceCards
                  // ignore: prefer_const_constructors
                  // Container(
                  //   margin: const EdgeInsets.symmetric(
                  //       horizontal: 16, vertical: 16),
                  //   height: 80,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.withOpacity(0.4),
                  //         spreadRadius: 1,
                  //         blurRadius: 6,
                  //         offset: const Offset(0, 6),
                  //       ),
                  //     ],
                  //   ),
                  //   padding:
                  //       const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  //   child: Row(
                  //     children: [
                  //       Column(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Container(
                  //             width: 55,
                  //             height: 55,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               shape: BoxShape.circle,
                  //               border:
                  //                   Border.all(color: Colors.white, width: 3),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.grey.withOpacity(0.3),
                  //                   spreadRadius: 2,
                  //                   blurRadius: 6,
                  //                   offset: const Offset(0, 3),
                  //                 ),
                  //               ],
                  //             ),
                  //             child: ClipOval(
                  //               child: controller
                  //                               .childrenList
                  //                               .first
                  //                               .selectedMealMenuData!
                  //                               .first
                  //                               .imageUrl !=
                  //                           null &&
                  //                       controller
                  //                           .childrenList
                  //                           .first
                  //                           .selectedMealMenuData!
                  //                           .first
                  //                           .imageUrl!
                  //                           .isNotEmpty
                  //                   ? Image.network(
                  //                       controller
                  //                           .childrenList
                  //                           .first
                  //                           .selectedMealMenuData!
                  //                           .first
                  //                           .imageUrl!,
                  //                       width: double.infinity,
                  //                       fit: BoxFit.cover,
                  //                       loadingBuilder:
                  //                           (context, child, loadingProgress) {
                  //                         if (loadingProgress == null)
                  //                           return child;
                  //                         return const Center(
                  //                           child: CircularProgressIndicator(),
                  //                         );
                  //                       },
                  //                       errorBuilder:
                  //                           (context, error, stackTrace) {
                  //                         return const Icon(
                  //                             Icons.error_outline);
                  //                       },
                  //                     )
                  //                   : Image.asset(
                  //                       'assets/images/profile_emoji.png',
                  //                       width: double.infinity,
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(width: 12),
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Text(
                  //                   controller.childrenList.first.childName ??
                  //                       "N/A",
                  //                   style:
                  //                       AppTextStyles.MetropolisMedium.copyWith(
                  //                     fontSize: 14,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             Text(
                  //               controller.childrenList.first.schoolName ??
                  //                   "N/A",
                  //               style: AppTextStyles.MetropolisRegular.copyWith(
                  //                 fontSize: 12,
                  //                 color: const Color(0xFF858585),
                  //               ),
                  //             ),
                  //             Text(
                  //               controller.childrenList.first.childSchoolID ??
                  //                   "N/A",
                  //               style: AppTextStyles.MetropolisRegular.copyWith(
                  //                 fontSize: 12,
                  //                 color: const Color(0xFF858585),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // // Padding(
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

                  // Remove the bottom START PREPARATION button
                  // Obx(
                  //   () => CustomButton1(
                  //       text: 'START PREPARATION',
                  //       onPressed: () async {
                  //         final parentId =
                  //             controller.childrenList.first.parentId;
                  //         if (parentId != null) {
                  //           print("parent id is $parentId");

                  //           await controller.fetchChildParentWallet(parentId);
                  //         } else {
                  //           Get.snackbar('Error', 'Child ID not found');
                  //         }
                  //       },
                  //       isLoading: controller.isLoading.value),
                  // ),

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
