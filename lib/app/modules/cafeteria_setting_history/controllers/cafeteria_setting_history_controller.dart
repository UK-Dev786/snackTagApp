import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafeteria_setting_history_service.dart';

class CafeteriaSettingHistoryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CafeteriaSettingHistoryService _historyService = CafeteriaSettingHistoryService();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedIndex = 0.obs;
  var orderHistory = <ParentsAddChildren>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("CafeteriaSettingHistoryController initialized");
    fetchHistoryData();
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
    update();
  }

  Future<void> fetchHistoryData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Get current user ID
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Fetch order history from service
      final orders = await _historyService.fetchOrderHistory(userId);
      
      // Update the observable list
      orderHistory.assignAll(orders);
      
      print("📋 Fetched ${orders.length} orders successfully");
      
    } catch (e) {
      errorMessage.value = 'Error fetching history data: $e';
      print("❌ Error in fetchHistoryData: $e");
    } finally {
      isLoading.value = false;
      update(['cafeteriaHistoryId']);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
