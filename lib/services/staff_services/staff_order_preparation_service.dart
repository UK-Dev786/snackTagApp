import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/cloud_functions_service.dart';
import 'package:snacktag/services/parents/parent_add_wallet_service.dart';

class StaffOrderPreparationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ParentAddWalletService _walletService = ParentAddWalletService();

  Future<UserModel?> getCafeteriaData(String cafeteriaId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection("users").doc(cafeteriaId).get();

      if (!doc.exists) {
        print("⚠️ No cafeteria found with ID: $cafeteriaId");
        return null;
      }

      print("📍 Fetched cafeteria data: ${doc.data()}");
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print("❌ Error fetching cafeteria data: $e");
      throw Exception("Failed to fetch cafeteria data: $e");
    }
  }

  // Stream to get real-time updates for orders in preparation
  Stream<List<ParentsAddChildren>> getOrdersInPreparation(
      String cafeteriaName) {
    return _firestore
        .collection('orderPreparation')
        .where('cafeteriaName', isEqualTo: cafeteriaName)
        .where('status', isEqualTo: 'in_preparation')
        .where('delivered', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      print("📦 Fetched ${snapshot.docs.length} orders in preparation");
      return snapshot.docs.map((doc) {
        print("Order Data: ${doc.data()}");
        return ParentsAddChildren.fromJson(doc.data());
      }).toList();
    });
  }

  // Stream to get real-time updates for orders in preparation
  Stream<List<ParentsAddChildren>> getDeliveredOrder(String cafeteriaName) {
    return _firestore
        .collection('orderPreparation')
        .where('cafeteriaName', isEqualTo: cafeteriaName)
        .where('status', isEqualTo: 'Delivered')
        .where('delivered', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      print("📦 Fetched ${snapshot.docs.length} Delivered orders");
      return snapshot.docs.map((doc) {
        print("Order Data: ${doc.data()}");
        return ParentsAddChildren.fromJson(doc.data());
      }).toList();
    });
  }

  // Method to update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orderPreparation').doc(orderId).update({
        'status': newStatus,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      print("✅ Order status updated successfully: $orderId -> $newStatus");
      return true;
    } catch (e) {
      print("❌ Error updating order status: $e");
      return false;
    }
  }

  // Method to mark order as delivered
  Future<bool> markOrderAsDelivered(String orderId, String deliveredBy) async {
    try {
      await _firestore.collection('orderPreparation').doc(orderId).update({
        'delivered': true,
        'status': 'Delivered',
        'orderDeliveredTime': DateTime.now().toIso8601String(),
        'startPreparation': false,
        'orderDeliveredBy': deliveredBy,
      });
      print("✅ Order marked as delivered: $orderId");
      return true;
    } catch (e) {
      print("❌ Error marking order as delivered: $e");
      return false;
    }
  }

  // Method to get specific order details
  Future<ParentsAddChildren?> getOrderDetails(String orderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('orderPreparation').doc(orderId).get();

      if (!doc.exists) {
        print("⚠️ Order not found: $orderId");
        return null;
      }

      return ParentsAddChildren.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("❌ Error fetching order details: $e");
      return null;
    }
  }

  // Method to process payout to cafeteria admin
  Future<bool> processCafeteriaAdminPayout(
      String cafeteriaId, double amount) async {
    try {
      // Get the cafeteria admin's Stripe account ID
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(cafeteriaId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        print("❌ Cafeteria admin user document not found: $cafeteriaId");
        return false;
      }

      final userData = userDoc.data()!;
      final stripeAccountId = userData['stripeAccountId'];

      if (stripeAccountId == null) {
        print("❌ No Stripe account ID found for cafeteria admin: $cafeteriaId");
        return false;
      }

      // Convert amount to cents for Stripe
      final amountInCents = (amount * 100).toInt();

      // Call the payout cloud function
      final cloudFunctionsService = Get.find<CloudFunctionsService>();
      final response = await cloudFunctionsService.callFunction('payout', {
        'amount': amountInCents,
        'stripeAccountId': stripeAccountId,
      });

      if (response != null && response['data'] != null) {
        print(
            "✅ Payout processed successfully for cafeteria admin: $cafeteriaId");
        return true;
      } else {
        print("❌ Failed to process payout: ${response ?? 'No response'}");
        return false;
      }
    } catch (e) {
      print("❌ Error processing payout: $e");
      return false;
    }
  }

  // Method to deduct payment from parent wallet
  Future<bool> deductPaymentFromParentWallet(
      String parentId, double amount) async {
    try {
      // Validate inputs
      if (parentId.isEmpty) {
        print("❌ Invalid parent ID provided");
        return false;
      }

      if (amount <= 0) {
        print("❌ Invalid amount: $amount. Amount must be greater than 0");
        return false;
      }

      // Deduct payment from parent wallet
      bool success =
          await _walletService.deductPaymentFromWallet(parentId, amount);

      if (success) {
        print(
            "✅ Payment of $amount successfully deducted from parent wallet: $parentId");
      } else {
        print("❌ Failed to deduct payment from parent wallet: $parentId");
      }

      return success;
    } catch (e) {
      print("❌ Error deducting payment from parent wallet: $e");
      return false;
    }
  }
}
