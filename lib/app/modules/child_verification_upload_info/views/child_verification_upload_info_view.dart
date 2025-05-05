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
                  
                  // Add student name below image
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      controller.childrenList.first.childName ?? "Student",
                      style: AppTextStyles.MetropolisMedium.copyWith(
                        fontSize: 16,
                        color: const Color(0xFF434343),
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
                            'Today\'s Meals ($currentDayName)',
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
                                    if (meal.schedule == null ||
                                        meal.schedule!.repeatOn == null ||
                                        meal.schedule!.repeatOn!.isEmpty) {
                                      return false;
                                    }

                                    return meal.schedule!.repeatOn!.any((day) {
                                      // Check if day is a number (index) or a string (day name)
                                      try {
                                        final dayIndex = int.parse(day);
                                        return dayIndex == currentDayOfWeek;
                                      } catch (e) {
                                        // If not a number, compare day names
                                        return day.trim().toLowerCase() ==
                                            currentDayName.toLowerCase();
                                      }
                                    });
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
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Meal image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: meal.imageUrl != null &&
                                                meal.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                meal.imageUrl!,
                                                width: 100,
                                                height: 100,
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
                                                    width: 100,
                                                    height: 100,
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
                                                width: 100,
                                                height: 100,
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
                                              Text(
                                                meal.mealName ?? 'Unnamed Meal',
                                                style: AppTextStyles
                                                    .MetropolisMedium.copyWith(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              // Display meal time if available
                                              if (meal.schedule != null && 
                                                  meal.schedule!.availableAt != null && 
                                                  meal.schedule!.availableAt!.isNotEmpty)
                                                Text(
                                                  'Time: ${meal.schedule!.availableAt!.join(", ")}',
                                                  style: AppTextStyles.MetropolisRegular.copyWith(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '\$${meal.mealPrice ?? "0.00"}',
                                                style: AppTextStyles
                                                    .MetropolisMedium.copyWith(
                                                  fontSize: 16,
                                                  color:
                                                      const Color(0xFFFC6011),
                                                ),
                                              ),
                                              
                                              // Add preparation button
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    // Check if current time is within the allowed preparation window
                                                    bool isWithinTimeWindow = false;
                                                    String timeMessage = "";
                                                    
                                                    if (meal.schedule != null && 
                                                        meal.schedule!.availableAt != null && 
                                                        meal.schedule!.availableAt!.isNotEmpty) {
                                                      
                                                      final now = DateTime.now();
                                                      final currentHour = now.hour;
                                                      
                                                      // Check each available time
                                                      for (String timeStr in meal.schedule!.availableAt!) {
                                                        int scheduledHour = 0;
                                                        
                                                        // Parse the time string (e.g., "9am", "2pm")
                                                        if (timeStr.contains('am')) {
                                                          scheduledHour = int.parse(timeStr.replaceAll('am', ''));
                                                          // Handle 12am as 0 hour
                                                          if (scheduledHour == 12) scheduledHour = 0;
                                                        } else if (timeStr.contains('pm')) {
                                                          scheduledHour = int.parse(timeStr.replaceAll('pm', ''));
                                                          // Add 12 for PM times, except 12pm
                                                          if (scheduledHour != 12) scheduledHour += 12;
                                                        }
                                                        
                                                        // Check if current time is within ±1 hour window
                                                        if (currentHour >= scheduledHour - 1 && 
                                                            currentHour <= scheduledHour + 1) {
                                                          isWithinTimeWindow = true;
                                                          break;
                                                        }
                                                      }
                                                      
                                                      if (!isWithinTimeWindow) {
                                                        timeMessage = "This meal can only be prepared within 1 hour of its scheduled time.";
                                                      }
                                                    } else {
                                                      // If no schedule is defined, allow preparation at any time
                                                      isWithinTimeWindow = true;
                                                    }
                                                    
                                                    if (isWithinTimeWindow) {
                                                      final parentId = controller.childrenList.first.parentId;
                                                      if (parentId != null) {
                                                        await controller.fetchChildParentWallet(parentId, meal);
                                                      } else {
                                                        Get.snackbar('Error', 'Parent ID not found');
                                                      }
                                                    } else {
                                                      Get.snackbar(
                                                        'Outside Preparation Window', 
                                                        timeMessage,
                                                        backgroundColor: Colors.orange,
                                                        colorText: Colors.white,
                                                        duration: const Duration(seconds: 3),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFFFC6011), Color(0xFFFF8D41)],
                                                        begin: Alignment.centerLeft,
                                                        end: Alignment.centerRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    child: Text(
                                                      'Start Preparation',
                                                      style: AppTextStyles.MetropolisRegular.copyWith(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
