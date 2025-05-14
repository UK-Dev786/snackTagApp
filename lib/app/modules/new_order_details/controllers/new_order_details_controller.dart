import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/staff_services/staff_order_preparation_service.dart';

class NewOrderDetailsController extends GetxController {
  final StaffOrderPreparationService _preparationService =
      StaffOrderPreparationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final Rx<ParentsAddChildren?> orderData = Rx<ParentsAddChildren?>(null);
  final RxString parentName = ''.obs;
  final RxString childName = ''.obs;
  final RxString childImageUrl = ''.obs;
  final RxString schoolName = ''.obs;
  final RxString childId = ''.obs;
  final RxBool hasOrderId = false.obs;

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
        var parentId = Get.arguments['parentId'] as String?;
        var childNameArg = Get.arguments['childName'] as String?;

        // Store child name from arguments
        if (childNameArg != null && childNameArg.isNotEmpty) {
          childName.value = childNameArg;
        }

        // Fetch parent details if available
        if (parentId != null && parentId.isNotEmpty) {
          fetchParentDetails(parentId);

          // If we don't have an order ID but have parent ID and child name,
          // try to fetch the child details from the parent's children collection
          if ((orderId == null || orderId.isEmpty) &&
              childNameArg != null &&
              childNameArg.isNotEmpty) {
            fetchChildDetails(parentId, childNameArg);
          }
        }

        // If we have an order ID, fetch the order details
        if (orderId != null && orderId.isNotEmpty) {
          hasOrderId.value = true;
          fetchOrderDetails(orderId);
        } else {
          // We don't have an order ID, but we can still show some information
          hasOrderId.value = false;

          // Create a basic order data object with the information we have
          if (childNameArg != null && childNameArg.isNotEmpty) {
            orderData.value = ParentsAddChildren(
              childName: childNameArg,
              date: DateTime.now().toIso8601String(),
            );
          }

          isLoading.value = false;
          update(['newOrderDetailsId']);
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

  Future<void> fetchChildDetails(String parentId, String childName) async {
    try {
      print("Fetching child details for parent: $parentId, child: $childName");

      // Query the parentChildren collection to find the child
      QuerySnapshot childrenSnapshot = await _firestore
          .collection('parentChildren')
          .where('parentId', isEqualTo: parentId)
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        // Look for a child with matching name
        for (var doc in childrenSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (data['childName'] != null &&
              data['childName'].toString().toLowerCase() ==
                  childName.toLowerCase()) {
            print("Found matching child: ${data['childName']}");

            // Update the child information
            childId.value = doc.id;
            childImageUrl.value = data['childImageUrl'] ?? '';
            schoolName.value = data['schoolName'] ?? '';

            // Update the order data with more complete information
            orderData.value = ParentsAddChildren(
              childId: doc.id,
              childName: data['childName'],
              childImageUrl: data['childImageUrl'],
              schoolName: data['schoolName'],
              childSchoolID: data['childSchoolID'],
              date: DateTime.now().toIso8601String(),
            );

            update(['newOrderDetailsId']);
            break;
          }
        }
      } else {
        print("No children found for parent: $parentId");
      }
    } catch (e) {
      print("Error fetching child details: $e");
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      print("Fetching order details for ID: $orderId");

      // First try to get the order from the orderPreparation collection
      ParentsAddChildren? orderDetails =
          await _preparationService.getOrderDetails(orderId);

      if (orderDetails != null) {
        orderData.value = orderDetails;
        print(
            "Fetched order details from orderPreparation: ${orderDetails.childName}");
      } else {
        // If not found in orderPreparation, try the parentsChildren collection
        print(
            "Order not found in orderPreparation, trying parentsChildren collection");
        DocumentSnapshot doc =
            await _firestore.collection('parentsChildren').doc(orderId).get();

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          orderData.value = ParentsAddChildren.fromJson(data);
          print(
              "Fetched order details from parentsChildren: ${orderData.value?.childName}");
        } else {
          print("Order not found in parentsChildren either");
          errorMessage.value = 'Order details not found';
        }
      }
    } catch (e) {
      errorMessage.value = 'Error fetching order details: $e';
      print("Error in fetchOrderDetails: $e");
    } finally {
      isLoading.value = false;
      update(['newOrderDetailsId']);
    }
  }

  Future<void> fetchParentDetails(String parentId) async {
    try {
      print("Fetching parent details for ID: $parentId");

      // Get parent details from Firestore
      DocumentSnapshot parentDoc =
          await _firestore.collection('users').doc(parentId).get();

      if (parentDoc.exists && parentDoc.data() != null) {
        Map<String, dynamic> data = parentDoc.data() as Map<String, dynamic>;

        // Try different field names for parent name
        if (data['parentsName'] != null &&
            data['parentsName'].toString().isNotEmpty) {
          parentName.value = data['parentsName'];
          print("Found parent name (parentsName): ${parentName.value}");
        } else if (data['name'] != null && data['name'].toString().isNotEmpty) {
          parentName.value = data['name'];
          print("Found parent name (name): ${parentName.value}");
        } else {
          parentName.value = 'Parent';
          print("No parent name found, using default: Parent");
        }
      } else {
        print("Parent document not found for ID: $parentId");
        parentName.value = 'Parent';
      }
    } catch (e) {
      print("Error fetching parent details: $e");
      parentName.value = 'Parent';
    }
  }
}
