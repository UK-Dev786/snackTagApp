import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
// import 'package:snacktag/app/routes/app_routes.dart';t';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/services/cloud_functions_service.dart';
import 'package:snacktag/widgets/Custom_search_textfield.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';

import 'package:snacktag/widgets/reuse_button.dart';

import '../../stripe_onboarding/view/stripe_onboarding_view.dart';
import '../controllers/cafeteria_menu_page_controller.dart';

class CafeteriaMenuPageView extends GetView<CafeteriaMenuPageController> {
  const CafeteriaMenuPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          // color: Colors.red,
          child: Stack(
            children: [
              ListView(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 70,
                        ),

                        // Settings Title
                        Text(
                          'SELECT MEAL', // Title text
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 18,
                            color: const Color(0xFF434343),
                          ),
                        ),
                        const SizedBox(
                            height: 42), // Spacing between title and list
                        _buildSearchField(controller.searchTextController),
                        const SizedBox(height: 30),
                        _buildText(),
                        const SizedBox(height: 32),

                        _buildMenuList(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  // _buildBottomFixedButton(),
                ],
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: _buildBottomFixedButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Search TextField Widget (moved slightly down)
  Widget _buildSearchField(TextEditingController textController) {
    // return TextFieldWidget(
    //   text: 'Search Meal',
    //   textController: textController,
    //   path: 'assets/icon/search.png',
    //   isBGChangeColor: true,
    //   height: 40,
    //   isSuffixBG: true,
    //   onChanged: (value) => controller.updateSearchText(value),
    // );
    return SearchTextFieldWidget(
      hintText: 'Search Meal',
      textController: textController,
      onChanged: (value) => controller.updateSearchText(value),
    );
  }

  // "Congratulations" text in the center
  Widget _buildText() {
    return Obx(
      () => Center(
        child: Text(
          '${controller.schoolName.value} / ${controller.cafeteriaName}', // Replace with dynamic text
          style: AppTextStyles.PoppinsBold.copyWith(
            fontSize: 14,
            color: AppColors.blackColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : controller.isDataFound.value == true
            ? Text(
                'Data Not Found', // Replace with dynamic text
                style: AppTextStyles.PoppinsBold.copyWith(
                  fontSize: 14,
                  color: AppColors.blackColor,
                ),
              )
            : controller.meals.isEmpty
                ? Text(
                    'Meal Not Available', // Replace with dynamic text
                    style: AppTextStyles.PoppinsBold.copyWith(
                      fontSize: 14,
                      color: AppColors.blackColor,
                    ),
                  )
                :
                // GridView.builder(
                //             shrinkWrap: true,
                //             physics: const NeverScrollableScrollPhysics(),
                //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //               crossAxisCount: 3,
                //               mainAxisSpacing: 16,
                //               crossAxisSpacing: 8,
                //               childAspectRatio: 100 / 170,
                //             ),
                //             itemCount: controller.searchText.value.isEmpty
                //                 ? controller.meals.length
                //                 : controller.filteredMeals.length,
                //             itemBuilder: (context, index) {
                //               return _buildMenuItem(
                //                 controller.searchText.value.isEmpty
                //                     ? controller.meals[index]
                //                     : controller.filteredMeals[index],
                //               );
                //             },
                //           )
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 8,
                      childAspectRatio: 100 / 170,
                    ),
                    itemCount: controller.filteredMeals.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItem(controller.filteredMeals[index]);
                    },
                  ));
  }

  Widget _buildMenuItem(
    MealModel meal,
  ) {
    final controller = Get.find<CafeteriaMenuPageController>();

    // ✅ Ensure every meal has a switch controller
    if (!controller.switchControllers.containsKey(meal.id)) {
      controller.switchControllers[meal.id!] =
          ValueNotifier<bool>(meal.availability == 'available');
    }

    // final _controller = ValueNotifier<bool>(meal.availability == 'available');

    final switchController = controller.switchControllers[meal.id]!;
    // print("Switch Value is :${_controller}");

    // ✅ Debugging prints

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image from Firestore
            meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                ? Image.network(
                    meal.imageUrl!,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ));
                    },
                  )
                : Image.asset(
                    'assets/images/gravy.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          meal.name ?? 'Unnamed Item',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (meal.id != null) {
                            controller.deleteMeal(meal.id!);
                          }
                        },
                        child: Image.asset(
                          'assets/icon/delete.png',
                          width: 15,
                          height: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${meal.price ?? "0"}',
                    style: AppTextStyles.MetropolisMedium.copyWith(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ Advanced Switch with ValueNotifier
                  ValueListenableBuilder<bool>(
                    valueListenable: switchController,
                    builder: (context, value, child) {
                      return AdvancedSwitch(
                        controller: switchController,
                        activeColor: Color(0xFFCCFD00),
                        height: 12,
                        width: 25,
                        onChanged: (newValue) {
                          controller.updateMeal(meal.id!, newValue);
                        },
                      );
                    },
                  ),
                  // AdvancedSwitch(
                  //   controller: _controller,
                  //   activeColor: Colors.green,
                  //   height: 12,
                  //   width: 25,
                  //   onChanged: (value) {
                  //     if (meal.id != null) {
                  //       controller.updateMeal(
                  //           meal.id!, {'availability': value ? 'available' : 'unavailable'});
                  //     }
                  //   },
                  // ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.CAFETERIA_MEAL_DETAILS,
                        arguments: meal, // Pass MealModel as argument
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFEFEFEF),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF707070).withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: Text(
                        'Edit',
                        style: AppTextStyles.PoppinsRegular.copyWith(
                          fontSize: 7,
                          color: const Color(0xFFFFAA00),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Fixed Button
  Widget _buildBottomFixedButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomButton(
        height: 55,
        width: double.infinity,
        text: 'Add',
        onPressed: () async {
          if (controller.isButtonLoading.value) return;

          controller.isButtonLoading.value = true;
          try {
            // Show loading indicator
            Get.snackbar('Processing', 'Checking account status...');

            // First check if the user already has a Stripe account
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              Get.snackbar(
                  'Error', 'User not authenticated. Please log in again.');
              return;
            }

            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            // Use proper logging instead of print
            developer.log('User document data: ${userDoc.data()}',
                name: 'CafeteriaMenuPage');

            // Check if user has a Stripe account - MUST have stripeAccountId
            // We need the actual account ID for payouts, so just having onboarding complete is not enough
            final hasStripeAccount = userDoc.exists &&
                userDoc.data() != null &&
                userDoc.data()!['stripeAccountId'] != null;

            // Log the check results for debugging
            developer.log(
                'Stripe account check: hasStripeAccount=$hasStripeAccount, '
                'stripeAccountId=${userDoc.data()?['stripeAccountId']}, '
                'stripeOnboardingComplete=${userDoc.data()?['stripeOnboardingComplete']}',
                name: 'CafeteriaMenuPage');

            // Handle different Stripe account states
            if (userDoc.exists && userDoc.data() != null) {
              // Case 1: User has stripeAccountId but stripeOnboardingComplete is not set
              // Update it to ensure future checks work correctly
              if (userDoc.data()!['stripeAccountId'] != null &&
                  userDoc.data()!['stripeOnboardingComplete'] != true) {
                developer.log(
                    'Updating Stripe onboarding status for existing account',
                    name: 'CafeteriaMenuPage');

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'stripeOnboardingComplete': true,
                    'stripeOnboardingDate': FieldValue.serverTimestamp(),
                  });
                } catch (e) {
                  developer.log('Error updating Stripe status: $e',
                      name: 'CafeteriaMenuPage');
                }
              }
              // Case 2: User has stripeOnboardingComplete but no stripeAccountId
              // This is an invalid state - we need to reset and have them go through onboarding again
              else if (userDoc.data()!['stripeOnboardingComplete'] == true &&
                  userDoc.data()!['stripeAccountId'] == null) {
                developer.log(
                    'Invalid state: onboarding complete but no account ID. Resetting onboarding status.',
                    name: 'CafeteriaMenuPage');

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'stripeOnboardingComplete': false,
                  });

                  // Show a message to the user
                  Get.snackbar(
                    'Account Setup Required',
                    'Your Stripe account setup is incomplete. Please complete the setup to continue.',
                    duration: const Duration(seconds: 5),
                    backgroundColor: Colors.orange[100],
                    colorText: Colors.orange[800],
                  );
                } catch (e) {
                  developer.log('Error resetting Stripe status: $e',
                      name: 'CafeteriaMenuPage');
                }
              }
            }

            if (hasStripeAccount) {
              // User already has a Stripe account, go directly to meal details
              Get.snackbar(
                'Account Already Set Up',
                'You already have a Stripe account configured.',
                duration: const Duration(seconds: 3),
              );
              // Navigate directly to add meal page
              Get.toNamed(Routes.CAFETERIA_MEAL_DETAILS);
              return;
            }

            // If no account exists, create one
            Get.snackbar('Processing', 'Setting up your Stripe account...');

            final response = await Get.find<CloudFunctionsService>()
                .callFunction('createSnackTagStripeAccount', {});

            if (response != null &&
                response['link'] != null &&
                response['account'] != null) {
              // Store the Stripe account ID in Firestore
              try {
                final stripeAccountId = response['account']['id'];
                developer.log('Storing Stripe account ID: $stripeAccountId',
                    name: 'CafeteriaMenuPage');

                // Update the user document with the Stripe account ID
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'stripeAccountId': stripeAccountId,
                  'stripeAccountCreatedAt': FieldValue.serverTimestamp(),
                });

                // Open Stripe onboarding in WebView
                Get.to(() => StripeOnboardingView(
                      url: response['link']['url'],
                      stripeAccountId:
                          stripeAccountId, // Pass the account ID to the WebView
                    ));
              } catch (e) {
                developer.log('Error storing Stripe account ID: $e',
                    name: 'CafeteriaMenuPage');
                Get.snackbar('Warning',
                    'Account created but ID storage failed. Please contact support.');
              }
            } else {
              Get.snackbar('Error', 'Invalid response from server');
              developer.log(
                  'Invalid response from createSnackTagStripeAccount: $response',
                  name: 'CafeteriaMenuPage');
            }
          } catch (e) {
            final errorMsg = e.toString();
            final truncatedMsg = errorMsg.length > 100
                ? '${errorMsg.substring(0, 100)}...'
                : errorMsg;
            Get.snackbar(
                'Error', 'Failed to create Stripe account: $truncatedMsg',
                duration: const Duration(seconds: 5));
          } finally {
            controller.isButtonLoading.value = false;
          }
        },
        isLoading: controller.isButtonLoading,
      ),
    );
  }
}
