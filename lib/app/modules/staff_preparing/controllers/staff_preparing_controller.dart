import 'dart:convert'; // Import for json

import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_history/controllers/staff_history_controller.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffOrderPreparingController extends GetxController {
  final StaffOrderPreparationService _preparationService =
      StaffOrderPreparationService();
  final UserPreferences _preferences = UserPreferences();
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<ParentsAddChildren> preparingOrdersList =
      <ParentsAddChildren>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<StaffModel?> staffData = Rx<StaffModel?>(null);
  final Rx<UserModel?> cafeteriaData = Rx<UserModel?>(null);
  final RxString cafeteriaName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeStaffData();
  }

  Future<void> _initializeStaffData() async {
    try {
      isLoading.value = true;

      // Fetch staff data from preferences
      StaffModel? staffModel = await _preferences.getStaffDataPreference();

      if (staffModel != null) {
        staffData.value = staffModel;

        // Fetch cafeteria data using staff's userId
        if (staffModel.userId != null) {
          try {
            UserModel? cafeteria =
                await _preparationService.getCafeteriaData(staffModel.userId!);
            if (cafeteria != null) {
              cafeteriaData.value = cafeteria;
              cafeteriaName.value = cafeteria.cafeteriaName ?? '';
              print("📱 Cafeteria Data loaded - Name: ${cafeteriaName.value}");

              // Only start listening to orders if we have a cafeteria name
              if (cafeteriaName.value.isNotEmpty) {
                _listenToOrders();
              } else {
                print("⚠️ No cafeteria name found in cafeteria data");
                Get.snackbar(
                  'Warning',
                  'Cafeteria name not found',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            }
          } catch (e) {
            print("❌ Error fetching cafeteria data: $e");
            Get.snackbar(
              'Error',
              'Failed to load cafeteria information',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          print("⚠️ No userId found in staff data");
          Get.snackbar(
            'Warning',
            'Staff information incomplete',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print("❌ No staff data found in preferences");
        Get.snackbar(
          'Error',
          'Staff data not found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("❌ Error initializing staff data: $e");
      Get.snackbar(
        'Error',
        'Failed to load staff data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToOrders() {
    if (cafeteriaName.value.isEmpty) return;

    _preparationService.getOrdersInPreparation(cafeteriaName.value).listen(
      (orders) {
        preparingOrdersList.assignAll(orders);
        update(['staffOrderPreparingId']);
        print("📋 Updated orders list: ${orders.length} orders");
      },
      onError: (error) {
        print("❌ Error listening to orders: $error");
        Get.snackbar(
          'Error',
          'Failed to load orders',
          snackPosition: SnackPosition.TOP,
        );
      },
    );
  }

  Future<void> markAsDelivered(
      String orderId, String orderPrepareStaffname) async {
    isLoading.value = true;
    try {
      if (staffData.value!.staffName == orderPrepareStaffname) {
        // First, get the order details to get the price
        ParentsAddChildren? orderDetails =
            await _preparationService.getOrderDetails(orderId);

        if (orderDetails == null) {
          Get.snackbar(
            'Error',
            'Order details not found',
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        // Calculate total amount from all meal prices
        double totalAmount = 0;
        if (orderDetails.selectedMealMenuData != null &&
            orderDetails.selectedMealMenuData!.isNotEmpty) {
          for (var meal in orderDetails.selectedMealMenuData!) {
            if (meal.mealPrice != null && meal.mealPrice!.isNotEmpty) {
              // Remove $ sign if present and parse to double
              String priceStr = meal.mealPrice!.replaceAll('\$', '');
              try {
                double price = double.parse(priceStr);
                totalAmount += price;
              } catch (e) {
                print("❌ Error parsing meal price: $e");
              }
            }
          }
        }

        // Check if we have a valid parent ID and amount to deduct
        bool paymentDeducted = false;
        if (orderDetails.parentId != null &&
            orderDetails.parentId!.isNotEmpty &&
            totalAmount > 0) {
          // Deduct payment from parent wallet
          paymentDeducted =
              await _preparationService.deductPaymentFromParentWallet(
                  orderDetails.parentId!,
                  totalAmount,
                  orderDetails.childId ?? ''); // Add childId parameter

          if (!paymentDeducted) {
            print(
                "⚠️ Failed to deduct payment from parent wallet: ${orderDetails.parentId}");
            // Show snackbar to staff and don't deliver the order
            Get.snackbar(
              'Payment Failed',
              'Cannot deliver order. Insufficient funds in parent wallet.',
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 5),
            );
            return; // Exit the function early without delivering the order
          }
        }

        // Process payout to cafeteria admin if we have the necessary data
        bool payoutSuccess = false;
        double commissionPercentage = 0;
        double payoutAmount = 0;

        if (orderDetails.cafeteriaId != null && totalAmount > 0) {
          // Fetch commission percentage from AppSettings collection
          try {
            final appSettingsDoc = await FirebaseFirestore.instance
                .collection('AppSettings')
                .doc('paymentSettings')
                .get();

            print("📄 App Settings document exists: ${appSettingsDoc.exists}");
            if (appSettingsDoc.exists) {
              print("📄 App Settings data: ${appSettingsDoc.data()}");
            }

            var rawCommissionData = appSettingsDoc.data()!;
            print("📊 Raw commission data: $rawCommissionData");

            // Extract the snackTagCommission value
            // var rawCommission = rawCommissionData['snackTagComission'];
            // print(
            // "📊 Raw commission value: $rawCommission (${rawCommission.runtimeType})");

            // Handle different data types
            commissionPercentage = 0;
            // if (rawCommission is int) {
            //   commissionPercentage = rawCommission.toDouble();
            // } else if (rawCommission is double) {
            //   commissionPercentage = rawCommission;
            // } else if (rawCommission is String) {
            // commissionPercentage = double.tryParse(rawCommission) ?? 0;
            // } else {
            //   // Try to handle any other unexpected format
            //   try {
            commissionPercentage =
                double.parse(rawCommissionData['snackTagComission'].toString());
            //   } catch (e) {
            //     print("❌ Error parsing commission value: $e");
            //     commissionPercentage = 0;
            //   }
            // }

            print(
                "📊 SnackTag commission percentage (parsed): $commissionPercentage%");

            // Calculate commission amount
            double commissionAmount =
                (totalAmount * commissionPercentage / 100);

            // Calculate payout amount after deducting commission
            payoutAmount = totalAmount - commissionAmount;

            print("💰 Total amount: $totalAmount");
            print("💰 Commission percentage: $commissionPercentage%");
            print("💰 Commission amount: $commissionAmount");
            print("💰 Payout amount: $payoutAmount");

            // Make sure paymentDetails is a valid Firestore map
            // Use ISO string for timestamps instead of FieldValue.serverTimestamp()
            // as the latter can only be used directly with set() and update()
            Map<String, dynamic> paymentDetails = {
              'paymentProcessed': true,
              'paymentDetails': {
                'totalAmount': totalAmount,
                'commissionPercentage': commissionPercentage,
                'commissionAmount': commissionAmount,
                'payoutAmount': payoutAmount,
                'processedAt': DateTime.now().toIso8601String(),
                'processedBy': staffData.value!.staffName,
                'status': 'processing'
              }
            };

            // Then update the document
            await _firestore
                .collection('orderPreparation')
                .doc(orderId)
                .update(paymentDetails);

            // Process payout with the new amount
            payoutSuccess =
                await _preparationService.processCafeteriaAdminPayout(
                    orderDetails.cafeteriaId!,
                    payoutAmount,
                    orderId); // Pass orderId instead of transaction ID

            // Update payment status based on payout result
            if (payoutSuccess) {
              // Update payment status to completed
              await _firestore
                  .collection('orderPreparation')
                  .doc(orderId)
                  .update({
                'paymentDetails.status': 'completed',
                'paymentDetails.payoutCompletedAt':
                    DateTime.now().toIso8601String(),
                'paymentDetails.payoutResponse': 'success'
              });

              // Now that payout is successful, mark the order as delivered
              bool success = await _preparationService.markOrderAsDelivered(
                  orderId,
                  staffData.value!.staffName!,
                  staffData.value!.staffPhone ??
                      ''); // Pass staff ID if available

              if (success) {
                // Send notification to parent about order delivery
                if (orderDetails.parentId != null &&
                    orderDetails.parentId!.isNotEmpty) {
                  try {
                    await sendOrderDeliveredNotification(
                      parentId: orderDetails.parentId!,
                      childName: orderDetails.childName ?? 'your child',
                      staffName: staffData.value!.staffName ?? 'staff',
                      orderId: orderId,
                    );
                  } catch (e) {
                    print("Error sending delivery notification to parent: $e");
                    // Log the error but don't rethrow to avoid disrupting the main flow
                  }
                }

                // Send notification to cafe owner about order delivery
                try {
                  await sendOrderDeliveredNotificationToCafeOwner(
                    cafeteriaName: orderDetails.cafeteriaName ?? '',
                    childName: orderDetails.childName ?? 'a child',
                    staffName: staffData.value!.staffName ?? 'staff',
                    orderId: orderId,
                    totalAmount: totalAmount,
                  );
                } catch (e) {
                  print(
                      "Error sending delivery notification to cafe owner: $e");
                  // Log the error but don't rethrow to avoid disrupting the main flow
                }

                // Update history view
                final historyController = Get.find<StaffHistoryController>();
                historyController.updateSelectedIndex(1);

                // Show success message
                if (paymentDeducted) {
                  Get.snackbar(
                    'Success',
                    'Order delivered, payment processed with ${commissionPercentage.toStringAsFixed(1)}% commission',
                    snackPosition: SnackPosition.TOP,
                  );
                } else {
                  Get.snackbar(
                    'Success',
                    'Order delivered and payment processed to cafeteria',
                    snackPosition: SnackPosition.TOP,
                  );
                }
              }
            } else {
              // Update payment status to failed
              await _firestore
                  .collection('orderPreparation')
                  .doc(orderId)
                  .update({
                'paymentDetails.status': 'failed',
                'paymentDetails.payoutFailedAt':
                    DateTime.now().toIso8601String(),
                'paymentDetails.payoutResponse': 'failed'
              });

              // Show snackbar to staff and don't deliver the order
              Get.snackbar(
                'Payout Failed',
                'Please contect to your support to add bank details then try again later.',
                snackPosition: SnackPosition.TOP,
                duration: Duration(seconds: 5),
              );

              // If payment was deducted, refund it to the parent's wallet
              if (paymentDeducted && orderDetails.parentId != null) {
                await _preparationService.refundPaymentToParentWallet(
                    orderDetails.parentId!,
                    totalAmount,
                    orderDetails.childId ?? '');
              }

              return; // Exit the function early without delivering the order
            }
          } catch (e) {
            print("❌ Error processing commission and payout: $e");

            String errorMessage =
                'Order delivered but payment processing encountered an error';
            Map<String, dynamic> errorDetails = {
              'error': e.toString(),
              'timestamp': DateTime.now().toIso8601String()
            };

            // Check if the error contains Stripe account information
            if (e.toString().contains("Account not enabled for payouts")) {
              try {
                // Try to parse the error message to extract more details
                final errorString = e.toString();
                final jsonStart = errorString.indexOf('{');
                final jsonEnd = errorString.lastIndexOf('}') + 1;

                if (jsonStart >= 0 && jsonEnd > jsonStart) {
                  final jsonString = errorString.substring(jsonStart, jsonEnd);
                  final errorData = json.decode(jsonString);

                  // Extract detailed information
                  if (errorData['missingRequirements'] != null) {
                    final requirements = errorData['missingRequirements'];
                    if (requirements is List && requirements.isNotEmpty) {
                      errorMessage =
                          'Stripe account setup incomplete: ${requirements.join(", ")}';
                      errorDetails['missingRequirements'] = requirements;
                    }
                  }

                  // Add country information if available
                  if (errorData['country'] != null) {
                    errorDetails['country'] = errorData['country'];
                  }

                  // Add capabilities information if available
                  if (errorData['capabilities'] != null) {
                    errorDetails['capabilities'] = errorData['capabilities'];
                  }
                }
              } catch (parseError) {
                print(
                    "❌ Error parsing detailed error information: $parseError");
              }

              // Update the error message to be more helpful
              errorMessage =
                  'Stripe account setup incomplete. Please complete the account setup in the Stripe dashboard and ensure the "transfers" capability is enabled.';
            }

            // Update payment status to error with detailed information
            await _firestore
                .collection('orderPreparation')
                .doc(orderId)
                .update({
              'paymentDetails.status': 'error',
              'paymentDetails.error': e.toString(),
              'paymentDetails.errorDetails': errorDetails,
              'paymentDetails.errorAt': DateTime.now().toIso8601String()
            });

            // Show snackbar to staff and don't deliver the order
            Get.snackbar(
              'Payout Error',
              'Cannot deliver order. Error processing payout to cafeteria.',
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 5),
            );

            // If payment was deducted, refund it to the parent's wallet
            if (paymentDeducted && orderDetails.parentId != null) {
              await _preparationService.refundPaymentToParentWallet(
                  orderDetails.parentId!,
                  totalAmount,
                  orderDetails.childId ?? '');
            }

            return; // Exit the function early without delivering the order
          }
        } else {
          // No cafeteria ID or total amount is zero, so we can proceed with delivery
          // Mark the order as delivered - pass staff ID if available
          bool success = await _preparationService.markOrderAsDelivered(
              orderId,
              staffData.value!.staffName!,
              staffData.value!.staffPhone ?? ''); // Pass staff ID if available

          if (success) {
            // Send notification to parent about order delivery
            if (orderDetails.parentId != null &&
                orderDetails.parentId!.isNotEmpty) {
              try {
                await sendOrderDeliveredNotification(
                  parentId: orderDetails.parentId!,
                  childName: orderDetails.childName ?? 'your child',
                  staffName: staffData.value!.staffName ?? 'staff',
                  orderId: orderId,
                );
              } catch (e) {
                print("Error sending delivery notification to parent: $e");
                // Log the error but don't rethrow to avoid disrupting the main flow
              }
            }

            // Send notification to cafe owner about order delivery
            try {
              await sendOrderDeliveredNotificationToCafeOwner(
                cafeteriaName: orderDetails.cafeteriaName ?? '',
                childName: orderDetails.childName ?? 'a child',
                staffName: staffData.value!.staffName ?? 'staff',
                orderId: orderId,
                totalAmount: totalAmount,
              );
            } catch (e) {
              print("Error sending delivery notification to cafe owner: $e");
              // Log the error but don't rethrow to avoid disrupting the main flow
            }

            // Update history view
            final historyController = Get.find<StaffHistoryController>();
            historyController.updateSelectedIndex(1);

            // Show success message
            if (paymentDeducted) {
              Get.snackbar(
                'Success',
                'Order delivered and payment deducted from parent wallet',
                snackPosition: SnackPosition.TOP,
              );
            } else {
              Get.snackbar(
                'Success',
                'Order marked as delivered',
                snackPosition: SnackPosition.TOP,
              );
            }
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'You cannot deliver this order. It was prepared by another staff member.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print("❌ Error marking order as delivered: $e");
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    isLoading.value = true;
    try {
      bool success =
          await _preparationService.updateOrderStatus(orderId, newStatus);
      if (success) {
        Get.snackbar(
          'Success',
          'Order status updated',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("❌ Error updating order status: $e");
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to send notification when order is delivered
  Future<void> sendOrderDeliveredNotification({
    required String parentId,
    required String childName,
    required String staffName,
    required String orderId,
  }) async {
    try {
      // Get the child image URL from the order details
      ParentsAddChildren? orderDetails =
          await _preparationService.getOrderDetails(orderId);
      String? childImageUrl = orderDetails?.childImageUrl;
      String? schoolName = orderDetails?.schoolName;

      print(
          "Parent: Sending order delivered notification with childImageUrl: $childImageUrl, schoolName: $schoolName");

      // Get cafeteria name from the order details or from the staff data
      String? cafeteriaName = orderDetails?.cafeteriaName;
      if ((cafeteriaName == null || cafeteriaName.isEmpty) &&
          cafeteriaData.value != null) {
        cafeteriaName = cafeteriaData.value!.cafeteriaName;
      }

      await _notificationService.sendNotification(
        userId: parentId,
        title: childName,
        // body:
        //     'received ${getMealTimeFromOrder(orderDetails)} meal from ${cafeteriaName ?? "cafeteria"}',
        body: 'received ${getMealTimeFromOrder(orderDetails)} meal',
        type: 'order_delivered',
        data: {
          'orderId': orderId,
          'deliveredBy': staffName,
          'notificationType': 'order_delivered',
          'childImageUrl':
              childImageUrl, // Include child image URL in notification data
          'schoolName': schoolName, // Include school name in notification data
          'childName': childName, // Include child name in notification data
          'cafeteriaName':
              cafeteriaName, // Include cafeteria name in notification data
        },
      );
      print("Parent: Order delivery notification sent to parent: $parentId");
    } catch (e) {
      print('Parent: Error sending order delivery notification: $e');
      // Don't rethrow to prevent disrupting the main flow
    }
  }

  // Helper method to get meal time from order
  String getMealTimeFromOrder(ParentsAddChildren? orderDetails) {
    if (orderDetails?.selectedMealMenuData != null &&
        orderDetails!.selectedMealMenuData!.isNotEmpty &&
        orderDetails.selectedMealMenuData![0].schedule?.availableAt != null &&
        orderDetails
            .selectedMealMenuData![0].schedule!.availableAt!.isNotEmpty) {
      return orderDetails.selectedMealMenuData![0].schedule!.availableAt![0];
    }
    return "scheduled";
  }

  // Method to send notification to cafe owner when order is delivered
  Future<void> sendOrderDeliveredNotificationToCafeOwner({
    required String cafeteriaName,
    required String childName,
    required String staffName,
    required String orderId,
    required double totalAmount,
  }) async {
    try {
      if (cafeteriaName.isEmpty) {
        print("CafeOwner: Cannot send notification - cafeteria name is empty");
        return;
      }

      // Find the cafeteria owner (user with cafeteriaName matching)
      QuerySnapshot ownerSnapshot = await _firestore
          .collection('users')
          .where('cafeteriaName', isEqualTo: cafeteriaName)
          .limit(1)
          .get();

      if (ownerSnapshot.docs.isEmpty) {
        print(
            "CafeOwner: No cafeteria owner found for cafeteria: $cafeteriaName");
        return;
      }

      // Get the cafeteria owner's ID
      String cafeteriaOwnerId = ownerSnapshot.docs.first.id;
      print("CafeOwner: Found cafeteria owner with ID: $cafeteriaOwnerId");

      // Get order details for additional information
      ParentsAddChildren? orderDetails =
          await _preparationService.getOrderDetails(orderId);
      String? childImageUrl = orderDetails?.childImageUrl;
      String? schoolName = orderDetails?.schoolName;

      // Apply the 10.5% commission to get the net amount for cafe owner
      double commissionPercentage = 10.5;
      double commissionAmount = (totalAmount * commissionPercentage / 100);
      double netAmount = totalAmount - commissionAmount;

      // Format amounts for display
      String formattedTotalAmount = totalAmount.toStringAsFixed(2);
      String formattedNetAmount = netAmount.toStringAsFixed(2);

      print("CafeOwner: Total amount: $formattedTotalAmount MXN");
      print("CafeOwner: Commission (10.5%): $commissionAmount MXN");
      print("CafeOwner: Net amount after commission: $formattedNetAmount MXN");

      // Send notification to cafe owner with the net amount after commission
      await _notificationService.sendNotification(
        userId: cafeteriaOwnerId,
        title: 'Order Delivered',
        body:
            '$staffName delivered $childName\'s order - $formattedNetAmount MXN',
        type: 'order_delivered',
        data: {
          'orderId': orderId,
          'deliveredBy': staffName,
          'notificationType': 'order_delivered',
          'childName': childName,
          'childImageUrl': childImageUrl,
          'schoolName': schoolName,
          'cafeteriaName': cafeteriaName,
          'amount': formattedNetAmount,
          'totalAmount': formattedTotalAmount,
          'commissionPercentage': commissionPercentage.toString(),
        },
      );

      print(
          "CafeOwner: Order delivery notification sent to cafe owner: $cafeteriaOwnerId");
    } catch (e) {
      print("CafeOwner: Error sending order delivery notification: $e");
      // Don't rethrow to prevent disrupting the main flow
    }
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
