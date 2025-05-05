
import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafateria_history_selectdate_service.dart';

class CafeteriaHistoryDetailsController extends GetxController {


  final CafaterisHistorySelectDateService cafaterisHistorySelectDateService =
  CafaterisHistorySelectDateService();
  //TODO: Implement CafeteriaHistoryDetailsController
  List<String>? orderStudentIds;
  var isLoading = false.obs;
  var childrenList = <ParentsAddChildren>[].obs;
  var errorMessage = ''.obs;

  final count = 0.obs;
  @override
  void onInit() {
    print("CafeteriaHistoryDetailsController onInit called");
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      print("Arguments received: ${Get.arguments}");
      orderStudentIds = List<String>.from(Get.arguments["orderStudentIds"] ?? []);
      print("Processed Student IDs: $orderStudentIds");
      if (orderStudentIds?.isNotEmpty ?? false) {
        fetchChildrenData();
      } else {
        errorMessage.value = 'No student IDs provided';
      }
    } else {
      print("No arguments received or invalid format");
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

      if (orderStudentIds == null || orderStudentIds!.isEmpty) {
        errorMessage.value = 'No student IDs to fetch';
        return;
      }

      final children = await cafaterisHistorySelectDateService.fetchChildrenByIds(orderStudentIds!);

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

  void increment() => count.value++;
}
