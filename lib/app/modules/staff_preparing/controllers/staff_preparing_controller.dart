import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_history/controllers/staff_history_controller.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';

class StaffOrderPreparingController extends GetxController {
  final StaffOrderPreparationService _preparationService =
      StaffOrderPreparationService();
  final UserPreferences _preferences = UserPreferences();
  final NotificationService _notificationService = NotificationService();

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
                  orderDetails.parentId!, totalAmount);

          if (!paymentDeducted) {
            print(
                "⚠️ Failed to deduct payment from parent wallet: ${orderDetails.parentId}");
            // We'll continue with the delivery process even if payment deduction fails
            // This is to ensure the child still gets their meal
          }
        }

        // Mark the order as delivered
        bool success = await _preparationService.markOrderAsDelivered(
            orderId, staffData.value!.staffName!);

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
            // Process payout to cafeteria admin
            bool payoutSuccess =
                await _preparationService.processCafeteriaAdminPayout(
                    orderDetails.cafeteriaId!, totalAmount);

            if (payoutSuccess) {
              if (paymentDeducted) {
                Get.snackbar(
                  'Success',
                  'Order delivered, payment deducted from parent wallet, and payment processed to cafeteria',
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
              if (paymentDeducted) {
                Get.snackbar(
                  'Warning',
                  'Order delivered and payment deducted from parent wallet, but payment processing to cafeteria failed',
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
      await _notificationService.sendNotification(
        userId: parentId,
        title: 'Order Delivered',
        body: 'The order for $childName has been delivered by $staffName',
        type: 'order_delivered',
        data: {
          'orderId': orderId,
          'deliveredBy': staffName,
          'notificationType': 'order_delivered',
        },
      );
      print("Order delivery notification sent to parent: $parentId");
    } catch (e) {
      print('Error sending order delivery notification: $e');
      // Don't rethrow to prevent disrupting the main flow
    }
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
