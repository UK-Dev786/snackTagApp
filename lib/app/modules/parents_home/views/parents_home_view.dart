import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_wallet_widget.dart';
import 'package:snacktag/widgets/parent_header.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import '../controllers/parents_home_controller.dart';

class ParentsHomeView extends GetView<ParentsHomeController> {
  const ParentsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller for switch
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ParentsHomeController>(
          init: ParentsHomeController(),
          builder: (parentController) {
            return Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 370,
                    child: ParentsHeader(),
                  ),
                  // Total Wallet Balance Section
                  // const SizedBox(
                  //   height:
                  //       20, // Reduced spacing since we now have a fixed height header
                  // ),
                  // Text(
                  //   "\$${parentController.parentAddWalletModel.value?.amount}",
                  //   style: AppTextStyles.PoppinsMedium.copyWith(
                  //     fontSize: 40,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // Text(
                  //   "Total Wallet Balance",
                  //   style: AppTextStyles.MetropolisMedium.copyWith(
                  //     fontSize: 16,
                  //   ),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Enable Monthly Reload",
                  //       style: AppTextStyles.MetropolisMedium.copyWith(
                  //         fontSize: 13,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     AdvancedSwitch(
                  //       activeColor: Colors.green,
                  //       inactiveColor: Colors.grey,
                  //       controller: parentController.switchController,
                  //       width: 27,
                  //       height: 12,
                  //       onChanged: (val) {
                  //         parentController.toggleMonthlyReload(val);
                  //       },
                  //       initialValue: parentController.parentAddWalletModel
                  //               .value?.enableMonthlyReload ??
                  //           false,
                  //     )
                  //   ],
                  // ),

                  // Two Wallet Balance Cards
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                        itemCount: parentController
                            .childrenList.length, // Display 4 items
                        padding: const EdgeInsets.only(
                            top: 8), // Reduce the top padding
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 16,
                            ),
                        itemBuilder: (context, index) {
                          return Container(
                              height: 95,
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
                              child: Row(children: [
                                // Profile image wrapped with Container
                                Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .start, // Align image to top
                                  children: [
                                    SizedBox(height: 12),
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
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 6,
                                            offset: const Offset(
                                                0, 3), // shadow position
                                          ),
                                        ],
                                      ),
                                      child: parentController
                                                      .childrenList
                                                      .value[index]
                                                      .childImageUrl !=
                                                  null &&
                                              parentController
                                                  .childrenList
                                                  .value[index]
                                                  .childImageUrl!
                                                  .isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                parentController
                                                    .childrenList
                                                    .value[index]
                                                    .childImageUrl!,
                                                width: double.infinity,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ));
                                                },
                                              ),
                                            )
                                          : ClipOval(
                                              child: Image.asset(
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
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Get.toNamed(Routes.CAFETERIA);
                                              Get.toNamed(
                                                  Routes.PARENTS_CHILDREN_EDIT,
                                                  arguments: parentController
                                                      .childrenList[index]);
                                            },
                                            child: Text(
                                              "Edit",
                                              style: AppTextStyles
                                                  .MetropolisRegular.copyWith(
                                                fontSize: 12,
                                                color: const Color(0xFFFF9A0D),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // if (!isShowScan)
                                          GestureDetector(
                                            onTap: () {
                                              // final homeController = Get.find<ParentsAddWalletController>();
                                              ParentsHomeController()
                                                  .deleteChildrenById(
                                                      parentController
                                                          .childrenList
                                                          .value[index]
                                                          .parentId!,
                                                      parentController
                                                          .childrenList
                                                          .value[index]
                                                          .childId!);
                                            },
                                            child: Image.asset(
                                              'assets/icon/delete.png',
                                              width: 15,
                                              height: 15,
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        parentController.childrenList
                                            .value[index].childName!,
                                        style: AppTextStyles.MetropolisMedium
                                            .copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        parentController.childrenList
                                            .value[index].schoolName!,
                                        style: AppTextStyles.MetropolisRegular
                                            .copyWith(
                                                fontSize: 12,
                                                color: const Color(0xFF858585)),
                                      ),
                                      Text(
                                        parentController.childrenList
                                            .value[index].childSchoolID!,
                                        style: AppTextStyles.MetropolisRegular
                                            .copyWith(
                                                fontSize: 12,
                                                color: const Color(0xFF858585)),
                                      ),
                                    ])),
                                VerticalDivider(
                                    width: 20,
                                    thickness: 1.5,
                                    color: Colors.black.withOpacity(0.3)),
                                Column(
                                  children: [
                                    SizedBox(height: 4),
                                    Image.asset(
                                      AppImages.authImg,
                                      width: 36,
                                      height: 36,
                                    ),
                                    SizedBox(height: 9),
                                    Text(
                                      'MX\$250',
                                      style: AppTextStyles.MetropolisMedium
                                          .copyWith(fontSize: 13),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Monthly Spending',
                                      style: AppTextStyles.MetropolisMedium
                                          .copyWith(fontSize: 5),
                                    ),
                                  ],
                                )
                              ])

                              // return WalletBalanceCard(
                              //   isShowScan: false,
                              //   isDelivered: false,
                              //   isDuration: false,
                              //   isNoImage: false,
                              //   isPreparing: false,
                              //   isType: false,
                              //   isDeliveredBy: false,
                              //   isStaff: false,
                              //   childList: controller.childrenList.value[index], // Pass each child object
                              // );
                              );
                        }),
                  )),

                  // const SizedBox(height: 24),
                  // const WalletBalanceCard(
                  //   isShowScan: false,
                  //   isDelivered: false,
                  //   isDuration: false,
                  //   isNoImage: false,
                  //   isPreparing: false,
                  //   isDeliveredBy: false,
                  //   isType: false,
                  //   isStaff: false,
                  // ),
                  const SizedBox(height: 13),

                  // CustomButton(
                  //     text: 'ADD WALLET BALANCE',
                  //     onPressed: () {
                  //       Get.toNamed(Routes.PARENTS_ADD_WALLET);
                  //     },
                  //     isLoading: false.obs),

                  CustomButton(
                      text: 'ADD CHILD',
                      onPressed: () {
                        Get.toNamed(Routes.PARENTS_CHILDREN_DETAILS);
                      },
                      isLoading: false.obs),

                  const SizedBox(height: 14),
                ],
              ),
            );
          }),
    );
  }
}
