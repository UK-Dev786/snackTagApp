import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';

class CafeteriaSettingHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ParentsAddChildren>> fetchOrderHistory(
      String cafeteriaAdminId) async {
    try {
      print("📍 Fetching order history for cafeteria: $cafeteriaAdminId");

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('orderPreparation')
          .where('cafeteriaAdminId', isEqualTo: cafeteriaAdminId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("ℹ️ No orders found for cafeteria: $cafeteriaAdminId");
        return [];
      }

      List<ParentsAddChildren> orders = querySnapshot.docs.map((doc) {
        print("📦 Processing order: ${doc.id}");
        return ParentsAddChildren.fromJson(doc.data());
      }).toList();

      return orders;
    } catch (e) {
      print("❌ Error fetching order history: $e");
      throw Exception("Failed to fetch order history: $e");
    }
  }
}
