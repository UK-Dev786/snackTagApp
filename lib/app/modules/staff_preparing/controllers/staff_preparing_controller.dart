import 'dart:ffi';

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
            // We'll continue with the delivery process even if payment deduction fails
            // This is to ensure the child still gets their meal
          }
        }

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
              print("Error sending delivery notification: $e");
              // Log the error but don't rethrow to avoid disrupting the main flow
            }
          }

          // Process payout to cafeteria admin if we have the necessary data
          if (orderDetails.cafeteriaId != null && totalAmount > 0) {
            // Fetch commission percentage from AppSettings collection
            try {
              final appSettingsDoc = await FirebaseFirestore.instance
                  .collection('AppSettings')
                  .doc('paymentSettings')
                  .get();

              print(
                  "📄 App Settings document exists: ${appSettingsDoc.exists}");
              if (appSettingsDoc.exists) {
                print("📄 App Settings data: ${appSettingsDoc.data()}");
              }

              var rawCommissionData =
                  appSettingsDoc.data()! as Map<String, dynamic>;
              print("📊 Raw commission data: $rawCommissionData");

              // Extract the snackTagCommission value
              // var rawCommission = rawCommissionData['snackTagComission'];
              // print(
              // "📊 Raw commission value: $rawCommission (${rawCommission.runtimeType})");

              // Handle different data types
              double commissionPercentage = 0;
              // if (rawCommission is int) {
              //   commissionPercentage = rawCommission.toDouble();
              // } else if (rawCommission is double) {
              //   commissionPercentage = rawCommission;
              // } else if (rawCommission is String) {
              // commissionPercentage = double.tryParse(rawCommission) ?? 0;
              // } else {
              //   // Try to handle any other unexpected format
              //   try {
              commissionPercentage = double.parse(
                  rawCommissionData['snackTagComission'].toString());
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
              double payoutAmount = totalAmount - commissionAmount;

              print("💰 Total amount: $totalAmount");
              print("💰 Commission percentage: $commissionPercentage%");
              print("💰 Commission amount: $commissionAmount");
              print("💰 Payout amount: $payoutAmount");

              // Make sure paymentDetails is a valid Firestore map
              Map<String, dynamic> paymentDetails = {
                'paymentProcessed': true,
                'paymentDetails': {
                  'totalAmount': totalAmount,
                  'commissionPercentage': commissionPercentage,
                  'commissionAmount': commissionAmount,
                  'payoutAmount': payoutAmount,
                  'processedAt': FieldValue.serverTimestamp(),
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
              bool payoutSuccess =
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
                      FieldValue.serverTimestamp(),
                  'paymentDetails.payoutResponse': 'success'
                });

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
              } else {
                // Update payment status to failed
                await _firestore
                    .collection('orderPreparation')
                    .doc(orderId)
                    .update({
                  'paymentDetails.status': 'failed',
                  'paymentDetails.payoutFailedAt': FieldValue.serverTimestamp(),
                  'paymentDetails.payoutResponse': 'failed'
                });

                if (paymentDeducted) {
                  Get.snackbar(
                    'Warning',
                    'Order delivered and payment deducted, but payout to cafeteria failed',
                    snackPosition: SnackPosition.TOP,
                  );
                } else {
                  Get.snackbar(
                    'Warning',
                    'Order delivered but payment processing failed',
                    snackPosition: SnackPosition.TOP,
                  );
                }
              }
            } catch (e) {
              print("❌ Error processing commission and payout: $e");

              // Update payment status to error
              await _firestore
                  .collection('orderPreparation')
                  .doc(orderId)
                  .update({
                'paymentDetails.status': 'error',
                'paymentDetails.error': e.toString(),
                'paymentDetails.errorAt': FieldValue.serverTimestamp()
              });

              Get.snackbar(
                'Warning',
                'Order delivered but payment processing encountered an error',
                snackPosition: SnackPosition.TOP,
              );
            }
          } else {
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

          // Update history view
          final historyController = Get.find<StaffHistoryController>();
          historyController.updateSelectedIndex(1);
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
        title: '$childName',
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

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
