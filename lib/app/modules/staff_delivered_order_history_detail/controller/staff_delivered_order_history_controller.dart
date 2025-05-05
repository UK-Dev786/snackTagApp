import 'package:get/get.dart';

import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafateria_history_selectdate_service.dart';
import 'package:snacktag/services/staff_services/staff_history_calendar_service.dart';

class StaffDeliveredOderHistoryDetailsController extends GetxController {
  final StaffHistoryCalendarService cafaterisHistorySelectDateService = StaffHistoryCalendarService();
  //TODO: Implement CafeteriaHistoryDetailsController
  List<String>? orderStudentIds;
  var isLoading = false.obs;
  var childrenList = <ParentsAddChildren>[].obs;
  var errorMessage = ''.obs;
  final Rx<ParentsAddChildren?> deliveredOrderData = Rx<ParentsAddChildren?>(null);

  @override
  void onInit() {
    super.onInit();
    print("StaffDeliveredOderHistoryDetailsController onInit called");

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      var receivedData = Get.arguments['DeliveredOrderData'] as ParentsAddChildren?;
      if (receivedData != null) {
        deliveredOrderData.value = receivedData;
        childrenList.assignAll([receivedData]); // Wrap the single object in a list
        print("Received delivered ordsdfgsadfer data: ${deliveredOrderData.value?.toJson()}");
        // If you need to fetch additional data based on the received order
        // fetchChildrenData();
      } else {
        errorMessage.value = 'No order data received';
        print("No delivered order data received");
      }
    } else {
      errorMessage.value = 'Invalid arguments received';
      print("Invalid or no arguments received");
    }
  }
  // Future<void> fetchCafateriaChildren() async {
  //   isLoading.value = true;
  //
  //   List<ParentsAddChildren> children = await cafaterisHistorySelectDateService
  //       .fetchChildrenByCafateriaName(cafateriaAdminName!);
  //   childrenList.assignAll(children);
  //   print("children data is  $children");
  //
  //   isLoading.value = false;
  //   update(['cafateriaHistorySelectDataId']);
  // }

  Future<void> fetchChildrenData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (deliveredOrderData.value == null) {
        errorMessage.value = 'No order data available';
        return;
      }

      // Assuming you need to fetch additional children data
      // Modify this according to your actual data requirements
      final children = await cafaterisHistorySelectDateService.fetchChildrenByIds([deliveredOrderData.value!.id!]);

      if (children.isEmpty) {
        errorMessage.value = 'No children found';
      } else {
        childrenList.assignAll(children);
        print("Fetched ${children.length} children successfully");
      }
    } catch (e) {
      errorMessage.value = 'Error fetching children data: $e';
      print("Error in fetchChildrenData: $e");
    } finally {
      isLoading.value = false;
      update(['cafeteriaHistoryDetailsId']);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
