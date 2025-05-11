import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';

class CafeteriaSettingHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ParentsAddChildren>> fetchOrderHistory(
      String cafeteriaAdminId) async {
    try {
      print("📍 Fetching order history for cafeteria admin: $cafeteriaAdminId");

      // Changed from 'cafeteriaAdminId' to 'cafeteriaId' to match the field name used when creating orders
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('orderPreparation')
          .where('cafeteriaId', isEqualTo: cafeteriaAdminId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("ℹ️ No orders found for cafeteria admin: $cafeteriaAdminId");

        // Debug: Try to find any orders in the collection to verify it exists
        QuerySnapshot<Map<String, dynamic>> allOrders =
            await _firestore.collection('orderPreparation').limit(5).get();

        print(
            "📊 Debug: Found ${allOrders.docs.length} total orders in collection");
        if (allOrders.docs.isNotEmpty) {
          print(
              "📊 Debug: Sample order fields: ${allOrders.docs.first.data().keys.join(', ')}");
        }

        return [];
      }

      print("📊 Found ${querySnapshot.docs.length} orders for cafeteria admin");

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
