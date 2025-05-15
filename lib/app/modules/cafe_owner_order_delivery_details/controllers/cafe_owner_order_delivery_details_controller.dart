import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';

class CafeOwnerOrderDeliveryDetailsController extends GetxController {
  final StaffOrderPreparationService _preparationService =
      StaffOrderPreparationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final Rx<ParentsAddChildren?> deliveredOrderData =
      Rx<ParentsAddChildren?>(null);

  // Variables to store amount information
  final RxString netAmount = '0.00'.obs;
  final RxString totalAmount = '0.00'.obs;
  final RxString commissionPercentage = '10.5'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrderData();
  }

  void loadOrderData() {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
        var orderId = Get.arguments['orderId'] as String?;

        // Get amount information from arguments if available
        if (Get.arguments['amount'] != null) {
          netAmount.value = Get.arguments['amount'].toString();
        }

        if (Get.arguments['totalAmount'] != null) {
          totalAmount.value = Get.arguments['totalAmount'].toString();
        }

        if (Get.arguments['commissionPercentage'] != null) {
          commissionPercentage.value =
              Get.arguments['commissionPercentage'].toString();
        }

        if (orderId != null && orderId.isNotEmpty) {
          fetchOrderDetails(orderId);
        } else {
          errorMessage.value = 'No order ID received';
          isLoading.value = false;
        }
      } else {
        errorMessage.value = 'Invalid arguments received';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading order data: $e';
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      // Get order details from Firestore
      ParentsAddChildren? orderDetails =
          await _preparationService.getOrderDetails(orderId);

      if (orderDetails != null) {
        deliveredOrderData.value = orderDetails;

        // If we didn't get amount from arguments, try to get it from order details
        if (netAmount.value == '0.00' &&
            orderDetails.selectedMealMenuData != null &&
            orderDetails.selectedMealMenuData!.isNotEmpty) {
          double total = 0.0;
          for (var meal in orderDetails.selectedMealMenuData!) {
            if (meal.mealPrice != null && meal.mealPrice!.isNotEmpty) {
              String priceStr = meal.mealPrice!.replaceAll('\$', '');
              try {
                double price = double.parse(priceStr);
                total += price;
              } catch (e) {
                print("Error parsing meal price: $e");
              }
            }
          }

          // Calculate net amount after commission
          double commission = total * 10.5 / 100;
          double net = total - commission;

          totalAmount.value = total.toStringAsFixed(2);
          netAmount.value = net.toStringAsFixed(2);
        }

        print("Fetched order details successfully: ${orderDetails.childName}");
      } else {
        errorMessage.value = 'Order details not found';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching order details: $e';
      print("Error in fetchOrderDetails: $e");
    } finally {
      isLoading.value = false;
      update(['cafeOwnerOrderDeliveryDetailsId']);
    }
  }
}
