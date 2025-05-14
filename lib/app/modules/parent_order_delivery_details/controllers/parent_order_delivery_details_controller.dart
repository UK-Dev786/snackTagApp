import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';

class ParentOrderDeliveryDetailsController extends GetxController {
  final StaffOrderPreparationService _preparationService = StaffOrderPreparationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final Rx<ParentsAddChildren?> deliveredOrderData = Rx<ParentsAddChildren?>(null);
  
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
        deliveredOrderData.value = orderDetails;
        print("Fetched order details successfully: ${orderDetails.childName}");
      } else {
        errorMessage.value = 'Order details not found';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching order details: $e';
      print("Error in fetchOrderDetails: $e");
    } finally {
      isLoading.value = false;
      update(['parentOrderDeliveryDetailsId']);
    }
  }
}
