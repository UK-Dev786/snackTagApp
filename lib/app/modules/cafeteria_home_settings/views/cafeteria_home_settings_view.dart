import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_add_staff/controllers/cafeteria_add_staff_controller.dart';
import 'package:snacktag/app/modules/cafeteria_add_staff/views/cafeteria_add_staff_view.dart';
import 'package:snacktag/app/modules/cafeteria_history_list/views/cafeteria_history_list_view.dart';
import 'package:snacktag/app/modules/cafeteria_settings/controllers/cafeteria_settings_controller.dart';
import 'package:snacktag/app/modules/cafeteria_settings/views/cafeteria_setting_widget.dart';
import 'package:snacktag/app/modules/cafeteria_settings/views/cafeteria_settings_view.dart';
import 'package:snacktag/app/modules/cafeteria_staff_list/views/cafeteria_staff_list_view.dart';
import 'package:snacktag/app/modules/profile/views/profile_view.dart';
import 'package:snacktag/app/routes/app_pages.dart';
// import 'package:snacktag/app/routes/app_routes.dart';t';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/services/cloud_functions_service.dart';
import 'package:snacktag/app/modules/stripe_onboarding/view/stripe_onboarding_view.dart';

import '../controllers/cafeteria_home_settings_controller.dart';

class CafeteriaHomeSettingsView extends GetView<CafeteriaSettingsController> {
  const CafeteriaHomeSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GetBuilder<CafeteriaSettingsController>(
              init: CafeteriaSettingsController(),
              builder: (controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 70,
                    ),

                    // Settings Title
                    Text(
                      'SETTINGS', // Title text
                      style: AppTextStyles.MetropolisMedium.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF434343),
                      ),
                    ),
                    // const SizedBox(height: 56), // Spacing between title and list

                    // define the row of setting page
                    const SizedBox(
                        height: 40), // Spacing between title and list
                    CafeteriaSettingWidget(
                      labelName: "Profile",
                      onTap: () {
                        Get.toNamed(Routes.PROFILE);
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Add Staff members",
                      onTap: () {
                        // Get.toNamed(Routes.CAFETERIA_ADD_STAFF, arguments: true);
                        Get.toNamed(Routes.CAFETERIA_STAFF_LIST);
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "History",
                      onTap: () {
                        Get.toNamed(Routes.CAFETERIA_SETTING_HISTORY);
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Privacy Policy",
                      onTap: () {
                        developer.log("Privacy Policy pressed",
                            name: "CafeteriaHomeSettings");
                        // TODO: Implement Privacy Policy action
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Terms & Conditions",
                      onTap: () {
                        developer.log("Terms & Conditions pressed",
                            name: "CafeteriaHomeSettings");
                        // TODO: Implement Terms & Conditions action
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Add/Change Bank Details",
                      onTap: () async {
                        try {
                          // Show loading indicator
                          Get.dialog(
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                            barrierDismissible: false,
                          );

                          // Get current user
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            if (Get.isDialogOpen == true) {
                              Get.back();
                            }
                            Get.snackbar(
                              'Error',
                              'User not logged in',
                              backgroundColor: Colors.red[100],
                              colorText: Colors.red[800],
                            );
                            return;
                          }

                          // Check if user already has a Stripe account ID
                          String? existingStripeAccountId;
                          try {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get();

                            if (userDoc.exists && userDoc.data() != null) {
                              existingStripeAccountId =
                                  userDoc.data()!['stripeAccountId'];
                              developer.log(
                                  '⚠️⚠️⚠️⚠️⚠️⚠️⚠️Found existing Stripe account ID: $existingStripeAccountId',
                                  name: 'CafeteriaHomeSettings');
                            }
                          } catch (e) {
                            developer.log(
                                'Error checking for existing Stripe account: $e',
                                name: 'CafeteriaHomeSettings');
                          }

                          // Call the cloud function to create a Stripe account or get the link
                          final cloudFunctionsService =
                              Get.find<CloudFunctionsService>();
                          final response = await cloudFunctionsService
                              .callFunction('createSnackTagStripeAccount', {});

                          // Close the loading dialog
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }

                          if (response != null && response['link'] != null) {
                            // Determine which Stripe account ID to use
                            String? stripeAccountId;
                            bool isNewAccount = false;

                            // If we have an existing account ID, use that
                            if (existingStripeAccountId != null &&
                                existingStripeAccountId.isNotEmpty) {
                              stripeAccountId = existingStripeAccountId;
                              developer.log(
                                  '😉😉😉😉Using existing Stripe account ID: $stripeAccountId',
                                  name: 'CafeteriaHomeSettings');
                            }
                            // Otherwise, use the new account ID from the response
                            else if (response['account'] != null) {
                              stripeAccountId = response['account']['id'];
                              isNewAccount = true;
                              developer.log(
                                  '❓❓❓❓Using new Stripe account ID: $stripeAccountId',
                                  name: 'CafeteriaHomeSettings');
                            }

                            // If we have a Stripe account ID (either existing or new)
                            if (stripeAccountId != null &&
                                stripeAccountId.isNotEmpty) {
                              try {
                                // Only update Firestore if this is a new account
                                if (isNewAccount) {
                                  developer.log(
                                      'Storing new Stripe account ID in Firestore: $stripeAccountId',
                                      name: 'CafeteriaHomeSettings');

                                  // Update the user document with the Stripe account ID
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .update({
                                    'stripeAccountId': stripeAccountId,
                                    'stripeAccountCreatedAt':
                                        FieldValue.serverTimestamp(),
                                  });
                                }

                                // Open Stripe onboarding in WebView
                                Get.to(() => StripeOnboardingView(
                                      url: response['link']['url'],
                                      stripeAccountId:
                                          stripeAccountId, // Pass the account ID to the WebView
                                    ));
                              } catch (e) {
                                developer.log(
                                    'Error storing Stripe account ID: $e',
                                    name: 'CafeteriaHomeSettings');
                                Get.snackbar(
                                  'Warning',
                                  'Account created but ID storage failed. Please contact support.',
                                  backgroundColor: Colors.orange[100],
                                  colorText: Colors.orange[800],
                                );
                              }
                            } else {
                              // No Stripe account ID available
                              Get.snackbar(
                                'Error',
                                'Could not determine Stripe account ID',
                                backgroundColor: Colors.red[100],
                                colorText: Colors.red[800],
                              );
                              developer.log('No Stripe account ID available',
                                  name: 'CafeteriaHomeSettings');
                            }
                          } else {
                            Get.snackbar(
                              'Error',
                              'Invalid response from server',
                              backgroundColor: Colors.red[100],
                              colorText: Colors.red[800],
                            );
                            developer.log(
                                'Invalid response from createSnackTagStripeAccount: $response',
                                name: 'CafeteriaHomeSettings');
                          }
                        } catch (e) {
                          // Close the loading dialog if open
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }

                          final errorMsg = e.toString();
                          final truncatedMsg = errorMsg.length > 100
                              ? '${errorMsg.substring(0, 100)}...'
                              : errorMsg;

                          Get.snackbar(
                            'Error',
                            'Failed to create Stripe account: $truncatedMsg',
                            backgroundColor: Colors.red[100],
                            colorText: Colors.red[800],
                            duration: const Duration(seconds: 5),
                          );
                        }
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Delete Account",
                      onTap: () {
                        Get.dialog(
                          Obx(() => controller.isLoading.value
                              ? Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),
                                          Text("Deleting account...",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : AlertDialog(
                                  title: Text("Delete Account",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.MetropolisRegular
                                          .copyWith(
                                        color: Colors.red,
                                        fontSize: 16,
                                      )),
                                  content: Text(
                                      "Are you sure you want to delete your account? This action cannot be undone.",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.MetropolisRegular
                                          .copyWith(
                                        color: const Color(0xFF4A4B4D),
                                        fontSize: 15,
                                      )),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back(); // Close dialog
                                      },
                                      child: Text("Cancel",
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            color: const Color(0xFF4A4B4D),
                                            fontSize: 14,
                                          )),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await controller.deleteAccount();
                                        Get.back(); // Close confirmation dialog
                                      },
                                      child: Text("Delete",
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            color: Colors.red,
                                            fontSize: 14,
                                          )),
                                    ),
                                  ],
                                )),
                          barrierDismissible: false,
                        );
                      },
                    ),
                    CafeteriaSettingWidget(
                      labelName: "Sign Out",
                      onTap: () {
                        controller.logout();
                        developer.log("User signed out",
                            name: "CafeteriaHomeSettings");
                      },
                    ),
                  ],
                );
              }),
        )
        // body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        //   Expanded(
        //     child: Obx(
        //       () => IndexedStack(
        //         index: controller
        //             .selectedIndex.value, // Bind the selected index to controller
        //         children: [
        //           GetBuilder<CafeteriaSettingsController>(
        //             init: CafeteriaSettingsController(),
        //             builder: (controller) => const CafeteriaSettingsView(),
        //           ),
        //           const ProfileView(),
        //           GetBuilder<CafeteriaAddStaffController>(
        //               init: CafeteriaAddStaffController(),
        //               builder: (controller)=> const CafeteriaAddStaffView()
        //
        //           ),
        //           const CafeteriaStaffListView(),
        //           // GetBuilder<CafeteriaAddStaffController>(
        //           //   init: CafeteriaAddStaffController(),
        //           //   builder: (controller)=> const CafeteriaAddStaffView(
        //           //   isEdit: true,
        //           // ),),
        //           const CafeteriaAddStaffView(
        //             isEdit: true,
        //           ),
        //           const CafeteriaHistoryListView(),
        //         ],
        //       ),
        //     ),
        //   ),
        // ]),
        );
  }
}
