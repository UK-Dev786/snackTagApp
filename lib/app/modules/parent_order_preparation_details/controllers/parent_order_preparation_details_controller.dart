import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';

const String parentOrderPreparationDetailsId = 'parentOrderPreparationDetailsId';

class ParentOrderPreparationDetailsController extends GetxController {
  final StaffOrderPreparationService _preparationService = StaffOrderPreparationService();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final Rx<ParentsAddChildren?> preparedOrderData = Rx<ParentsAddChildren?>(null);
  final RxString staffName = ''.obs;
  
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
        
        // Get the staff name from arguments if available
        if (Get.arguments.containsKey('preparedBy')) {
          staffName.value = Get.arguments['preparedBy'] as String? ?? 'Staff';
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
      ParentsAddChildren? orderDetails = await _preparationService.getOrderDetails(orderId);
      
      if (orderDetails != null) {
        preparedOrderData.value = orderDetails;
        print("Fetched order details successfully: ${orderDetails.childName}");
      } else {
        errorMessage.value = 'Order details not found';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching order details: $e';
      print("Error in fetchOrderDetails: $e");
    } finally {
      isLoading.value = false;
      update([parentOrderPreparationDetailsId]);
    }
  }
  
  // Get the preparation time string
  String getPreparationTimeString() {
    if (preparedOrderData.value?.orderPreparationDate != null &&
        preparedOrderData.value!.orderPreparationDate!.isNotEmpty) {
      try {
        DateTime parsedTime = DateTime.parse(preparedOrderData.value!.orderPreparationDate!);
        return 'Prepared on: ${parsedTime.toString()}';
      } catch (e) {
        print("Error parsing preparation time: $e");
        return 'Prepared recently';
      }
    }
    return 'Prepared recently';
  }
  
  // Get the staff name who prepared the order
  String getStaffName() {
    return preparedOrderData.value?.orderPreparedBy ?? staffName.value;
  }
}
