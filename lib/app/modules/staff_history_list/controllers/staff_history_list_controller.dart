import 'package:get/get.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';

class StaffHistoryListController extends GetxController {
  final StaffOrderPreparationService _preparationService =
      StaffOrderPreparationService();
  final UserPreferences _preferences = UserPreferences();
  //TODO: Implement StaffHistoryListController

  final count = 0.obs;
  final RxBool isLoading = false.obs;
  final Rx<StaffModel?> staffData = Rx<StaffModel?>(null);
  final Rx<UserModel?> cafeteriaData = Rx<UserModel?>(null);
  final RxString cafeteriaName = ''.obs;
  final RxList<ParentsAddChildren> deliveredOrdersList =
      <ParentsAddChildren>[].obs;

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
                // Get current month's orders by default
                final now = DateTime.now();
                fetchDeliveredOrdersForMonth(now.year, now.month);
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

    _preparationService.getDeliveredOrder(cafeteriaName.value).listen(
      (orders) {
        deliveredOrdersList.assignAll(orders);
        update(['staffOrderDeliveredId']);
        print("📋 Updated delivered orders list: ${orders.length} orders");
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

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // Add this method to filter orders by month
  void fetchDeliveredOrdersForMonth(int year, int month) {
    isLoading.value = true;

    // Calculate start and end dates for the month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of the month

    // Format dates for Firestore query
    final startDateStr = startDate.toIso8601String();
    final endDateStr = endDate.toIso8601String();

    if (cafeteriaName.value.isEmpty) {
      isLoading.value = false;
      return;
    }

    _preparationService
        .getDeliveredOrdersForDateRange(
            cafeteriaName.value, startDateStr, endDateStr)
        .then((orders) {
      // Filter to only include delivered orders
      final deliveredOrders = orders.where((order) => 
        order.status == 'Delivered' && 
        order.delivered == true
      ).toList();
      
      deliveredOrdersList.assignAll(deliveredOrders);
      update(['staffOrderDeliveredId']);
      print(
          "📋 Updated delivered orders list for $month/$year: ${deliveredOrders.length} orders");
      isLoading.value = false;
    }).catchError((error) {
      print("❌ Error fetching orders for month: $error");
      Get.snackbar(
        'Error',
        'Failed to load orders for the selected month',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
    });
  }
}
