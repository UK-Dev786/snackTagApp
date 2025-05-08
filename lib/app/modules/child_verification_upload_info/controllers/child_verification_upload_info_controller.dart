import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_history/controllers/staff_history_controller.dart';
import 'package:snacktag/app/modules/staff_landing_page/controllers/staff_landing_page_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';
import 'package:snacktag/models/parents_models/parent_selected_meals.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';
import 'package:snacktag/services/staff_services/child_verification_wallet_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChildVerificationUploadInfoController extends GetxController {
  final ChildVerificationWalletService _walletService =
      ChildVerificationWalletService();
  final NotificationService _notificationService = NotificationService();
  var childrenList = <ParentsAddChildren>[].obs;
  var isLoading = false.obs;
  final walletData = Rxn<ParentAddWalletModel>();
  late final StaffHistoryController historyController;
  final UserPreferences preferences = UserPreferences();
  StaffModel? staffModel;
  // Add this property to track meal statuses
  final mealStatuses = <String, RxString>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getStaffData();
    // Initialize StaffHistoryController if it doesn't exist

    if (!Get.isRegistered<StaffHistoryController>()) {
      Get.put(StaffHistoryController(),
          permanent: true); // Make it permanent here too
    }
    historyController = Get.find<StaffHistoryController>();

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      var receivedList =
          Get.arguments['childrenList'] as List<ParentsAddChildren>;
      if (receivedList.isNotEmpty) {
        childrenList.assignAll(receivedList);
        print("Received children data: ${childrenList.length} children");
      } else {
        print("No children data received");
      }
    } else {
      print("No arguments received or invalid format");
    }

    // Start checking meal statuses periodically
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (childrenList.isNotEmpty &&
          childrenList.first.selectedMealMenuData != null) {
        for (var meal in childrenList.first.selectedMealMenuData!) {
          checkMealStatus(meal);
        }
      }
    });
  }

  void getStaffData() async {
    staffModel = await preferences.getStaffDataPreference();
    print("staff name is ${staffModel?.staffName}");
  }

  Future<void> fetchChildParentWallet(
      String parentId, ParentSelectedMeals meal) async {
    try {
      isLoading.value = true;

      // First check if this specific meal has already been prepared today
      final childId = childrenList.first.childId;
      if (childId != null && childId.isNotEmpty) {
        final alreadyPrepared = await isMealAlreadyPreparedToday(childId, meal);

        if (alreadyPrepared) {
          Get.snackbar(
            'Already Prepared',
            'This meal has already been prepared today. You cannot prepare the same meal twice in a day.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isLoading.value = false;
          return;
        }
      }

      // Continue with the existing wallet balance check and preparation
      walletData.value = await _walletService.fetchChildParentWallet(parentId);

      if (walletData.value != null) {
        await checkWalletBalance(meal, parentId);
      } else {
        Get.snackbar('Error', 'Wallet not found');
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print("Error fetching wallet: $e");
      Get.snackbar('Error', 'Failed to fetch wallet data');
    }
  }

  // Check if the current day matches the scheduled day for the order
  bool isOrderForToday(ParentsAddChildren child) {
    try {
      // Get the current day of the week (0 = Sunday, 1 = Monday, etc.)
      final now = DateTime.now();
      final currentDayOfWeek =
          now.weekday % 7; // Convert to 0-6 format where 0 is Sunday

      // Get the day names for easier display in the snackbar
      final dayNames = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ];
      final currentDayName = dayNames[currentDayOfWeek];

      // Check if the child has meal data
      if (child.selectedMealMenuData == null ||
          child.selectedMealMenuData!.isEmpty) {
        print("No meal data available for this child");
        return true; // Allow preparation if no meal data (default behavior)
      }

      // Check each meal's schedule
      for (var meal in child.selectedMealMenuData!) {
        if (meal.schedule == null ||
            meal.schedule!.repeatOn == null ||
            meal.schedule!.repeatOn!.isEmpty) {
          print("No schedule data available for meal: ${meal.mealName}");
          continue; // Skip this meal if no schedule data
        }

        // Get the scheduled days for this meal
        final scheduledDays = meal.schedule!.repeatOn!;

        // Check if the current day is in the scheduled days
        bool isDayMatched = false;
        List<String> scheduledDayNames = [];

        for (var day in scheduledDays) {
          // Convert day string to index (assuming format like "0" for Sunday, "1" for Monday, etc.)
          try {
            final dayIndex = int.parse(day);
            scheduledDayNames.add(dayNames[dayIndex]);

            if (dayIndex == currentDayOfWeek) {
              isDayMatched = true;
              break;
            }
          } catch (e) {
            print("Error parsing day: $day - $e");
          }
        }

        // If this meal is scheduled for today, the order is valid for today
        if (isDayMatched) {
          return true;
        }

        // Store the scheduled days for this meal for the snackbar message
        print(
            "Meal ${meal.mealName} is scheduled for: ${scheduledDayNames.join(', ')}");
        // meal.scheduledDayNames = scheduledDayNames;
      }

      // If we get here, none of the meals are scheduled for today
      return false;
    } catch (e) {
      print("Error checking if order is for today: $e");
      return true; // Allow preparation if there's an error (default behavior)
    }
  }

  Future<void> checkWalletBalance(
      ParentSelectedMeals meal, String parentId) async {
    if (walletData.value == null || childrenList.isEmpty) {
      print("No wallet data or children data available");
      return;
    }

    double walletAmount = walletData.value!.amount;
    double mealPrice = double.parse(meal.mealPrice!);

    if (walletAmount < mealPrice) {
      await Get.dialog(
        AlertDialog(
          title: const Text('Insufficient Balance'),
          content: Text(
              'The parent\'s wallet balance (\$${walletAmount.toStringAsFixed(2)}) is less than the meal price (\$${mealPrice.toStringAsFixed(2)}).'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      sendLowBalanceNotification(
          walletData.value!.id!, walletAmount, mealPrice);
    } else {
      try {
        startPreparationOrder(childrenList.first, meal);
      } catch (e) {
        print("Navigation error: $e");
      }
    }
  }

  Future<void> sendLowBalanceNotification(
      String parentId, double walletAmount, double mealPrice) async {
    try {
      await _notificationService.sendNotification(
        userId: parentId,
        title: 'Low Wallet Balance Alert',
        body:
            'Your wallet balance (\$${walletAmount.toStringAsFixed(2)}) is insufficient for the meal order (\$${mealPrice.toStringAsFixed(2)}). Please recharge your wallet.',
        type: 'low_balance',
        data: {
          'currentBalance': walletAmount,
          'requiredAmount': mealPrice,
          'notificationType': 'low_balance',
        },
      );
      print("low balance notification sended ");
    } catch (e) {
      print('Error sending low balance notification: $e');
    }
  }

  Future<void> startPreparationOrder(
      ParentsAddChildren child, ParentSelectedMeals meal) async {
    try {
      isLoading.value = true;

      // Save the order preparation
      bool success = await _walletService.saveOrderPreparation(
          child, staffModel!.staffName!, staffModel!.userId!, meal);

      if (success) {
        // Update the local list item
        int index = childrenList
            .indexWhere((element) => element.childId == child.childId);
        if (index != -1) {
          childrenList[index].startPreparation = true;
          childrenList.refresh();
        }
        print("kkkkkk ${staffModel!.userId}");

        // Send notification to parent about order preparation
        if (child.parentId != null && child.parentId!.isNotEmpty) {
          try {
            // Try to get the latest order preparation document for this child
            ParentsAddChildren? latestOrder;
            try {
              latestOrder = await _walletService
                  .getLatestOrderPreparation(child.childId!);
            } catch (queryError) {
              print("Error querying latest order: $queryError");
              // Continue with null latestOrder
            }

            // Use the order ID if available, otherwise use an empty string
            String orderId = latestOrder?.orderPrepId ?? '';

            // Send the notification
            await sendOrderPreparedNotification(
              parentId: child.parentId!,
              childName: child.childName ?? 'your child',
              staffName: staffModel!.staffName ?? 'staff',
              orderPrepId: orderId,
            );
          } catch (e) {
            print("Error sending preparation notification: $e");
            // Log the error but don't rethrow to avoid disrupting the main flow
          }
        }

        Get.snackbar('Success', 'Order preparation started successfully',
            snackPosition: SnackPosition.TOP
            // backgroundColor: Colors.green,
            // colorText: Colors.white,
            );

        // Ensure the StaffLandingPageController exists
        if (!Get.isRegistered<StaffLandingPageController>()) {
          Get.put(StaffLandingPageController(), permanent: true);
        }
        final staffLandingPageController =
            Get.find<StaffLandingPageController>();

        // Set the index before navigation
        staffLandingPageController.selectedIndex.value = 1;
        historyController.updateSelectedIndex(0);

        // Navigate to landing page
        await Get.offAllNamed(Routes.STAFF_LANDING_PAGE,
            arguments: {'initialIndex': 1});
      } else {
        Get.snackbar('Error', 'Failed to start order preparation',
            snackPosition: SnackPosition.TOP
            // backgroundColor: Colors.red,
            // colorText: Colors.white,
            );
      }
    } catch (e) {
      print("❌ Error in startPreparationOrder: $e");
      Get.snackbar(
        'Error',
        'An error occurred while starting the preparation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to send notification when order preparation starts
  Future<void> sendOrderPreparedNotification({
    required String parentId,
    required String childName,
    required String staffName,
    required String orderPrepId,
  }) async {
    try {
      // Get the child image URL from the child data
      String? childImageUrl;
      if (childrenList.isNotEmpty) {
        childImageUrl = childrenList.first.childImageUrl;
      }

      print(
          "Parent: Sending order prepared notification with childImageUrl: $childImageUrl");

      await _notificationService.sendNotification(
        userId: parentId,
        title: 'Order Preparation Started',
        body: 'The order for $childName has been started by $staffName',
        type: 'order_prepared',
        data: {
          'orderId': orderPrepId,
          'preparedBy': staffName,
          'notificationType': 'order_prepared',
          'childImageUrl':
              childImageUrl, // Include child image URL in notification data
        },
      );
      print("Parent: Order preparation notification sent to parent: $parentId");
    } catch (e) {
      print('Parent: Error sending order preparation notification: $e');
    }
  }

  // Method to check and update meal status
  Future<void> checkMealStatus(ParentSelectedMeals meal) async {
    try {
      if (childrenList.isEmpty || meal.mealName == null) return;

      final childId = childrenList.first.childId;
      if (childId == null) return;

      // Format today's date
      final today = DateTime.now();
      final formattedToday = DateFormat('dd-MM-yyyy').format(today);

      // Create a unique key for this meal
      final mealKey = '${meal.mealName}_${formattedToday}';

      // Initialize status if not already set
      if (!mealStatuses.containsKey(mealKey)) {
        mealStatuses[mealKey] = 'Ready for Preparation'.obs;
      }

      print("Checking status for meal: ${meal.mealName} on $formattedToday");

      // Query Firestore to check if this meal is in preparation or delivered
      // Use a more inclusive query that doesn't filter by date to ensure we catch all orders
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orderPreparation')
          .where('childId', isEqualTo: childId)
          .get();

      print(
          "Found ${querySnapshot.docs.length} order documents for child $childId");

      bool foundMeal = false;

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          print("Checking order document: ${doc.id}");
          print(
              "Order status: ${data['status']}, delivered: ${data['delivered']}");

          final selectedMeals = data['selectedMealMenuData'] as List<dynamic>?;

          if (selectedMeals != null) {
            print("Order has ${selectedMeals.length} meals");

            for (var mealData in selectedMeals) {
              print(
                  "Checking meal: ${mealData['mealName']} against ${meal.mealName}");

              if (mealData['mealName'] == meal.mealName) {
                foundMeal = true;
                print("Found matching meal in order ${doc.id}");

                // Check order preparation date to ensure it's for today
                String? orderDate = data['orderPreparationDate'];
                if (orderDate != null) {
                  try {
                    DateTime orderDateTime = DateTime.parse(orderDate);
                    String formattedOrderDate =
                        DateFormat('dd-MM-yyyy').format(orderDateTime);

                    print(
                        "Order date: $formattedOrderDate, Today: $formattedToday");

                    // Only update status if the order is for today
                    if (formattedOrderDate == formattedToday) {
                      if (data['delivered'] == true) {
                        print("Setting status to Delivered");
                        mealStatuses[mealKey]?.value = 'Delivered';
                      } else if (data['startPreparation'] == true) {
                        print("Setting status to In Preparation");
                        mealStatuses[mealKey]?.value = 'In Preparation';
                      }
                      return; // Exit after finding a matching order for today
                    } else {
                      print("Order is not for today, continuing search");
                    }
                  } catch (e) {
                    print("Error parsing order date: $e");
                  }
                }
              }
            }
          }
        }
      }

      // If we get here and no matching order was found for today, it's ready for preparation
      if (!foundMeal) {
        print(
            "No matching order found for ${meal.mealName} today, setting status to Ready for Preparation");
        mealStatuses[mealKey]?.value = 'Ready for Preparation';
      }
    } catch (e) {
      print("Error checking meal status: $e");
    }
  }

  // Method to get the current status of a meal
  String getMealStatus(ParentSelectedMeals meal) {
    final today = DateTime.now();
    final formattedToday = DateFormat('dd-MM-yyyy').format(today);
    final mealKey = '${meal.mealName}_${formattedToday}';

    // Check status immediately if not already done
    if (!mealStatuses.containsKey(mealKey)) {
      mealStatuses[mealKey] = 'Ready for Preparation'.obs;
      checkMealStatus(meal);
    }

    return mealStatuses[mealKey]?.value ?? 'Ready for Preparation';
  }

  // Method to check if an order has already been prepared for this meal today
  Future<bool> isMealAlreadyPreparedToday(
      String childId, ParentSelectedMeals meal) async {
    try {
      // Get today's date at midnight (start of the day)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Convert to ISO string format for Firestore query
      final startOfDayStr = startOfDay.toIso8601String();
      final endOfDayStr = endOfDay.toIso8601String();

      print(
          "Checking for orders between $startOfDayStr and $endOfDayStr for meal: ${meal.mealName}");

      // Query for any orders prepared today for this child
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orderPreparation')
          .where('childId', isEqualTo: childId)
          .where('orderPreparationDate', isGreaterThanOrEqualTo: startOfDayStr)
          .where('orderPreparationDate', isLessThan: endOfDayStr)
          .get();

      // Check if any of the orders contain this specific meal
      bool mealAlreadyPrepared = false;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final selectedMeals = data['selectedMealMenuData'] as List<dynamic>?;

        if (selectedMeals != null) {
          for (var mealData in selectedMeals) {
            if (mealData['mealName'] == meal.mealName) {
              mealAlreadyPrepared = true;
              print("Found existing preparation for meal: ${meal.mealName}");
              break;
            }
          }
        }

        if (mealAlreadyPrepared) break;
      }

      return mealAlreadyPrepared;
    } catch (e) {
      print("Error checking if meal already prepared: $e");
      return false; // Default to false if there's an error
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
