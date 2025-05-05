import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/config/appBuilderId.dart';
import 'package:snacktag/config/app_text_style.dart';

import 'package:intl/intl.dart';

import '../../../../widgets/custom_wallet_widget.dart';
import '../../../../widgets/reuse_button.dart';
import '../controller/staff_delivered_order_history_controller.dart';

class StaffDeliveredOrderHistoryDetails extends StatelessWidget {
  const StaffDeliveredOrderHistoryDetails({super.key});
  @override
  Widget build(BuildContext context) {
    // final historyController = Get.find<StaffHistoryController>();
    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   body: SafeArea(
    //     child: SingleChildScrollView(
    //       child: ConstrainedBox(
    //         constraints: BoxConstraints(
    //           minHeight: MediaQuery.of(context).size.height -
    //               MediaQuery.of(context).padding.top,
    //         ),
    //         child: GetBuilder<StaffDeliveredOderHistoryDetailsController>(
    //           init: StaffDeliveredOderHistoryDetailsController(),
    //           id: staffOrderDeliveredId,
    //           builder: (controller) {
    //             return Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 // const SizedBox(height: 30),
    //                 // Title
    //                 Padding(
    //                   padding: const EdgeInsets.only(left: 20, top: 30),
    //                   child: GestureDetector(
    //                     onTap: () {
    //                       // controller.updateSelectedIndex(0);
    //                       Get.back();
    //                     },
    //                     child: Align(
    //                       alignment: Alignment.topLeft,
    //                       child: Container(
    //                         height: 35,
    //                         width: 35,
    //                         margin: const EdgeInsets.only(
    //                             top: 16), // Add some margin if needed
    //                         decoration: BoxDecoration(
    //                           shape: BoxShape.circle,
    //                           boxShadow: [
    //                             BoxShadow(
    //                               color: Colors.grey.withOpacity(0.2),
    //                               blurRadius: 4,
    //                               spreadRadius: 2,
    //                             ),
    //                           ],
    //                           color: Colors
    //                               .white, // Background color for the container
    //                         ),
    //                         child: Center(
    //                           child: Image.asset(
    //                             "assets/icon/back.png",
    //                             height: 15, // Set the height to 15
    //                             width: 10, // Set the width to 15
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 Center(
    //                   child: Text(
    //                     'Details',
    //                     style: AppTextStyles.MetropolisMedium.copyWith(
    //                       fontSize: 18,
    //                       color: const Color(0xFF434343),
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 20),
    //
    //                 // Month and Year
    //                 Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 32),
    //                   child: RichText(
    //                     text: TextSpan(
    //                       children: [
    //                         TextSpan(
    //                           text:
    //                           DateFormat('MMMM ').format(DateTime.now()),
    //                           style: AppTextStyles.RobotoLight.copyWith(
    //                             fontSize: 18,
    //                             color: const Color(0xFF2E2E2E),
    //                           ),
    //                         ),
    //                         TextSpan(
    //                           text: '${DateTime.now().year}',
    //                           style: AppTextStyles.RobotoBold.copyWith(
    //                             fontSize: 18,
    //                             color: const Color(0xFF2E2E2E),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //
    //                 const SizedBox(height: 20),
    //
    //                 // List of Orders
    //                 Obx(() {
    //                   if (controller.isLoading.value) {
    //                     return const Center(
    //                         child: CircularProgressIndicator());
    //                   }
    //
    //                   if (controller.errorMessage.value.isNotEmpty) {
    //                     return Center(
    //                       child: Text(controller.errorMessage.value),
    //                     );
    //                   }
    //
    //                   return ListView.separated(
    //                     shrinkWrap: true,
    //                     physics: const NeverScrollableScrollPhysics(),
    //                     padding: const EdgeInsets.symmetric(horizontal: 16),
    //                     itemCount: controller.childrenList.length,
    //                     separatorBuilder: (context, index) {
    //                       return Divider(
    //                         thickness: 1,
    //                         color: Colors.grey[300],
    //                       );
    //                     },
    //                     itemBuilder: (context, index) {
    //                       final child = controller.childrenList[index];
    //                       return Container(
    //                         height: 80,
    //                         decoration: BoxDecoration(
    //                           color: Colors.white,
    //                           borderRadius: BorderRadius.circular(12),
    //                           boxShadow: [
    //                             BoxShadow(
    //                               color: Colors.grey.withOpacity(0.4),
    //                               spreadRadius: 1,
    //                               blurRadius: 6,
    //                               offset: const Offset(0, 6),
    //                             ),
    //                           ],
    //                         ),
    //                         padding: const EdgeInsets.symmetric(
    //                             vertical: 8, horizontal: 16),
    //                         child: Row(
    //                           children: [
    //                             Column(
    //                               mainAxisAlignment: MainAxisAlignment.start,
    //                               children: [
    //                                 Container(
    //                                   width: 55,
    //                                   height: 55,
    //                                   decoration: BoxDecoration(
    //                                     color: Colors.white,
    //                                     shape: BoxShape.circle,
    //                                     border: Border.all(
    //                                         color: Colors.white, width: 3),
    //                                     boxShadow: [
    //                                       BoxShadow(
    //                                         color:
    //                                         Colors.grey.withOpacity(0.3),
    //                                         spreadRadius: 2,
    //                                         blurRadius: 6,
    //                                         offset: const Offset(0, 3),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   child: ClipOval(
    //                                     child: child.childImageUrl != null &&
    //                                         child
    //                                             .childImageUrl!.isNotEmpty
    //                                         ? Image.network(
    //                                       child.childImageUrl!,
    //                                       width: double.infinity,
    //                                       fit: BoxFit.cover,
    //                                       loadingBuilder: (context,
    //                                           child, loadingProgress) {
    //                                         if (loadingProgress == null)
    //                                           return child;
    //                                         return const Center(
    //                                           child:
    //                                           CircularProgressIndicator(),
    //                                         );
    //                                       },
    //                                       errorBuilder: (context, error,
    //                                           stackTrace) {
    //                                         return Image.asset(
    //                                           'assets/images/profile_emoji.png',
    //                                           width: double.infinity,
    //                                           fit: BoxFit.cover,
    //                                         );
    //                                       },
    //                                     )
    //                                         : Image.asset(
    //                                       'assets/images/profile_emoji.png',
    //                                       width: double.infinity,
    //                                       fit: BoxFit.cover,
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                             const SizedBox(width: 12),
    //                             Expanded(
    //                               child: Column(
    //                                 crossAxisAlignment:
    //                                 CrossAxisAlignment.start,
    //                                 children: [
    //                                   Row(
    //                                     mainAxisAlignment:
    //                                     MainAxisAlignment.spaceBetween,
    //                                     children: [
    //                                       Text(
    //                                         child.childName ?? "N/A",
    //                                         style: AppTextStyles
    //                                             .MetropolisMedium.copyWith(
    //                                           fontSize: 14,
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   Text(
    //                                     child.schoolName ?? "N/A",
    //                                     style: AppTextStyles.MetropolisRegular
    //                                         .copyWith(
    //                                       fontSize: 12,
    //                                       color: const Color(0xFF858585),
    //                                     ),
    //                                   ),
    //                                   Text(
    //                                     child.childSchoolID ?? "N/A",
    //                                     style: AppTextStyles.MetropolisRegular
    //                                         .copyWith(
    //                                       fontSize: 12,
    //                                       color: const Color(0xFF858585),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       );
    //                     },
    //                   );
    //                 }),
    //               ],
    //             );
    //           }),
    //       ),
    //     ),
    //   ),
    // );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: GetBuilder<StaffDeliveredOderHistoryDetailsController>(
            init: StaffDeliveredOderHistoryDetailsController(),
            id: staffOrderDeliveredId,
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          // historyController.updateSelectedIndex(0);
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          margin: const EdgeInsets.only(top: 16), // Add some margin if needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                            color: Colors.white, // Background color for the container
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

                  Center(
                    child: Text(
                      'Details',
                      style: AppTextStyles.MetropolisBold.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF434343),
                      ),
                    ),
                  ),

                  // Row with month/year and calendar icon
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                  ),

                  const SizedBox(width: 8),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
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
                        child: controller.deliveredOrderData.value!.childImageUrl != null &&
                                controller.deliveredOrderData.value!.childImageUrl!.isNotEmpty
                            ? Image.network(
                                controller.deliveredOrderData.value!.childImageUrl!,
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
                  ),
                  // First custom Row with text and image
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Student Photo',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Second custom Row with container, image, and texts
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 185,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            // shape: BoxShape.circle,
                            // border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Image taking 80% of the container height
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: controller.deliveredOrderData.value!.selectedMealMenuData![0].imageUrl != null &&
                                        controller.deliveredOrderData.value!.selectedMealMenuData![0].imageUrl!.isNotEmpty
                                    ? Image.network(
                                        height: 140,
                                        controller.deliveredOrderData.value!.selectedMealMenuData![0].imageUrl!,
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
                              // Bottom row with text and price
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 5.0, right: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.deliveredOrderData.value!.selectedMealMenuData![0].mealName!,
                                      style: AppTextStyles.MetropolisMedium.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '\$${controller.deliveredOrderData.value!.selectedMealMenuData![0].mealPrice}',
                                      style: AppTextStyles.MetropolisMedium.copyWith(
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

                  Container(
                    // height: 117,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 6), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile image wrapped with Container
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Align image to top
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
                                    offset: const Offset(0, 3), // shadow position
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: controller.deliveredOrderData.value!.childImageUrl != null &&
                                        controller.deliveredOrderData.value!.childImageUrl!.isNotEmpty
                                    ? Image.network(
                                        controller.deliveredOrderData.value!.childImageUrl!,
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
                                // Image.asset(
                                //   'assets/images/profile_emoji.png',
                                //   width: double.infinity,
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.deliveredOrderData.value!.childName ?? "",
                                    style: AppTextStyles.MetropolisMedium.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  // const Spacer(),
                                  // if (isEdit)
                                  //   GestureDetector(
                                  //     onTap: () {
                                  //       Get.toNamed(Routes.CAFETERIA);
                                  //     },
                                  //     child: Text(
                                  //       "Edit",
                                  //       style: AppTextStyles.MetropolisRegular.copyWith(
                                  //         fontSize: 12,
                                  //         color: const Color(0xFFFF9A0D),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // const SizedBox(width: 8),
                                  // if (!isShowScan)
                                  //   GestureDetector(
                                  //     onTap: () {
                                  //       // final homeController = Get.find<ParentsAddWalletController>();
                                  //       // ParentsHomeController().deleteChildrenById(childList!.parentId!,childList!.childId!);
                                  //     },
                                  //     child: Image.asset(
                                  //       'assets/icon/delete.png',
                                  //       width: 15,
                                  //       height: 15,
                                  //     ),
                                  //   )
                                ],
                              ),
                              Text(
                                controller.deliveredOrderData.value!.schoolName ?? "",
                                style: AppTextStyles.MetropolisRegular.copyWith(fontSize: 12, color: const Color(0xFF858585)),
                              ),
                              Text(
                                controller.deliveredOrderData.value!.childSchoolID ?? "",
                                style: AppTextStyles.MetropolisRegular.copyWith(fontSize: 12, color: const Color(0xFF858585)),
                              ),
                              // if (isType)
                              //   Row(
                              //     children: [
                              //       Text(
                              //         "Type: ",
                              //         style: AppTextStyles.MetropolisRegular.copyWith(
                              //             fontSize: 12, color: Colors.black),
                              //       ),
                              //       Text(
                              //         "Wallet Balance",
                              //         style: AppTextStyles.MetropolisRegular.copyWith(
                              //             fontSize: 12, color: const Color(0xFF858585)),
                              //       ),
                              //     ],
                              //   ),
                              // if (isDuration)
                              //   Row(
                              //     children: [
                              //       Text(
                              //         "Duration: ",
                              //         style: AppTextStyles.MetropolisRegular.copyWith(
                              //             fontSize: 12, color: Colors.black),
                              //       ),
                              //       Text(
                              //         "Weekly",
                              //         style: AppTextStyles.MetropolisRegular.copyWith(
                              //             fontSize: 12, color: const Color(0xFF858585)),
                              //       ),
                              //     ],
                              //   ),
                              // if (isStaff)
                              //   Row(
                              //     children: [
                              //       Text(
                              //         "Staff Name: ",
                              //         style: AppTextStyles.MetropolisRegular.copyWith(
                              //             fontSize: 12, color: Colors.black),
                              //       ),
                              //       Text(
                              //         "Name",
                              //         style: AppTextStyles.MetropolisRegular.copyWith(
                              //             fontSize: 12, color: const Color(0xFF858585)),
                              //       ),
                              //     ],
                              //   ),
                              // if (isDeliveredBy)
                              Row(
                                children: [
                                  Text(
                                    "Delivered By: ",
                                    style: AppTextStyles.MetropolisRegular.copyWith(fontSize: 12, color: Colors.black),
                                  ),
                                  Text(
                                    controller.deliveredOrderData.value!.orderDeliveredBy ?? "",
                                    style: AppTextStyles.MetropolisRegular.copyWith(fontSize: 12, color: const Color(0xFF858585)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // if (isPreparing)
                              //   Align(
                              //     alignment: Alignment.centerRight,
                              //     child: GradientButton(
                              //       height: 30,
                              //       width: 90,
                              //       onTap: () {
                              //         print("Preparing button tapped!");
                              //         // Add your onTap logic here
                              //       },
                              //     ),
                              //   ),
                              // if (isDelivered)
                              //   Align(
                              //     alignment: Alignment.centerRight,
                              //     child: Text(
                              //       "Delivered",
                              //       style: AppTextStyles.MetropolisMedium.copyWith(
                              //         fontSize: 12,
                              //         color: Colors.black,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),

                        // Vertical Divider
                        // isShowScan
                        // ?
                        Container(
                          width: 1,
                          color: Colors.black.withOpacity(0.1),
                          margin: const EdgeInsets.only(left: 6, right: 10),
                        ),
                        // : const SizedBox.shrink(),

                        // Wallet Balance Section
                        // isShowScan && !isNoImage
                        //     ? Column(
                        //         crossAxisAlignment: CrossAxisAlignment.end,
                        //         children: [
                        //           const SizedBox(height: 8),

                        //           Image.asset(
                        //             image,
                        //             width: 36,
                        //             height: 36,
                        //           ),

                        //           const SizedBox(height: 8),
                        //           // Divider
                        //           Container(
                        //             width: 40, // Adjust as needed
                        //             height: 1,
                        //             color: Colors.grey[300],
                        //           ),
                        //           const SizedBox(height: 8),
                        //           const SizedBox(height: 4),
                        //           Text(
                        //             price,
                        //             style: AppTextStyles.MetropolisMedium.copyWith(
                        //               fontSize: 16,
                        //               color: Colors.black,
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     : const SizedBox.shrink(),

                        // isNoImage
                        //     ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.deliveredOrderData.value!.selectedMealMenuData![0].mealPrice!,
                              style: AppTextStyles.MetropolisMedium.copyWith(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                        // : const SizedBox.shrink()
                      ],
                    ),
                  ),
                  // CustomButton(text: 'Confirm', onPressed: () {}, isLoading: false.obs),
                  SizedBox(
                    height: 16,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
