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
  Future<bool> markOrderAsDelivered(
      String orderId, String deliveredBy, String staffId) async {
    try {
      Map<String, dynamic> updateData = {
        'delivered': true,
        'status': 'Delivered',
        'orderDeliveredTime': DateTime.now().toIso8601String(),
        'startPreparation': false,
        'orderDeliveredBy': deliveredBy,
        'staffOrderDeliveredId': staffId, // Store staff ID properly
      };

      await _firestore
          .collection('orderPreparation')
          .doc(orderId)
          .update(updateData);
      print("✅ Order marked as delivered: $orderId by staff: $staffId");
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
      String cafeteriaId, double amount, String orderId) async {
    try {
      // Get the cafeteria admin's Stripe account ID
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(cafeteriaId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        print("❌ Cafeteria admin user document not found: $cafeteriaId");

        // Update order with error information
        await _firestore.collection('orderPreparation').doc(orderId).update({
          'paymentDetails.payoutLogs': FieldValue.arrayUnion([
            {
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'error',
              'message': 'Cafeteria admin user document not found',
            }
          ])
        });

        return false;
      }

      final userData = userDoc.data()!;
      final stripeAccountId = userData['stripeAccountId'];

      // Log user data to check country and other account details
      print("🏦 Cafeteria user data: ${userData.toString()}");
      print("🌎 Cafeteria country: ${userData['country'] ?? 'Not specified'}");
      print("💳 Stripe account ID: $stripeAccountId");

      // Check if Stripe onboarding is complete
      final bool stripeOnboardingComplete =
          userData['stripeOnboardingComplete'] ?? false;
      print("✅ Stripe onboarding complete: $stripeOnboardingComplete");

      // Check when the Stripe account was created
      final dynamic stripeAccountCreatedAt = userData['stripeAccountCreatedAt'];
      print("📅 Stripe account created at: $stripeAccountCreatedAt");

      // Check when onboarding was completed
      final dynamic stripeOnboardingDate = userData['stripeOnboardingDate'];
      print("📅 Stripe onboarding completed at: $stripeOnboardingDate");

      // Log additional details that might be useful
      print(
          "🔍 Cafeteria name: ${userData['cafeteriaName'] ?? 'Not specified'}");
      print("🏫 School name: ${userData['schoolName'] ?? 'Not specified'}");

      if (stripeAccountId == null) {
        print("❌ No Stripe account ID found for cafeteria admin: $cafeteriaId");

        // Update order with error information
        await _firestore.collection('orderPreparation').doc(orderId).update({
          'paymentDetails.payoutLogs': FieldValue.arrayUnion([
            {
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'error',
              'message': 'No Stripe account ID found for cafeteria admin',
            }
          ])
        });

        return false;
      }

      // Convert amount to cents for Stripe (ensuring it's rounded properly)
      final amountInCents = (amount * 100).round();

      print(
          "💸 Processing payout of $amount MXN ($amountInCents cents) to cafeteria: $cafeteriaId");
      print("💸 Using Stripe account ID: $stripeAccountId");

      // Update order with processing information
      await _firestore.collection('orderPreparation').doc(orderId).update({
        'paymentDetails.payoutLogs': FieldValue.arrayUnion([
          {
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'processing',
            'message': 'Processing payout',
            'amount': amount,
            'amountInCents': amountInCents,
            'stripeAccountId': stripeAccountId,
          }
        ])
      });

      // Call the payout cloud function
      final cloudFunctionsService = Get.find<CloudFunctionsService>();

      // Check the parameter names to match what the cloud function expects
      // The cloud function expects 'amount' and 'stripeAccountId' (or 'stripe_account_id')
      print("🔄 Calling payout function with parameters:");
      print("💰 Amount in cents: $amountInCents");
      print("🏦 Stripe account ID: $stripeAccountId");

      // Use the parameter names exactly as expected by the cloud function
      // Looking at index.js, the function expects 'amount' and 'stripe_account_id' or 'stripeAccountId'
      // Let's try both formats to ensure compatibility
      final response = await cloudFunctionsService.callFunction('payout', {
        'amount': amountInCents,
        'stripeAccountId': stripeAccountId,
        'stripe_account_id': stripeAccountId, // Add this as a fallback
      });

      if (response != null && response['data'] != null) {
        print(
            "✅ Payout processed successfully for cafeteria admin: $cafeteriaId");

        // Update order with success information
        await _firestore.collection('orderPreparation').doc(orderId).update({
          'paymentDetails.payoutLogs': FieldValue.arrayUnion([
            {
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'success',
              'message': 'Payout processed successfully',
              'response': response['data'],
            }
          ]),
          'paymentDetails.stripeResponse': response['data'],
        });

        return true;
      } else {
        print("❌ Failed to process payout: ${response ?? 'No response'}");

        // Update order with failure information
        await _firestore.collection('orderPreparation').doc(orderId).update({
          'paymentDetails.payoutLogs': FieldValue.arrayUnion([
            {
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'failed',
              'message': 'Failed to process payout',
              'response': response,
            }
          ])
        });

        return false;
      }
    } catch (e) {
      print("❌ Error processing payout: $e");

      // Update order with error information
      await _firestore.collection('orderPreparation').doc(orderId).update({
        'paymentDetails.payoutLogs': FieldValue.arrayUnion([
          {
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'error',
            'message': 'Error processing payout',
            'error': e.toString(),
          }
        ])
      });

      return false;
    }
  }

  // Method to deduct payment from parent wallet
  Future<bool> deductPaymentFromParentWallet(
      String parentId, double amount, String childId) async {
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

      if (success && childId.isNotEmpty) {
        // Update child's monthly expenditures only if childId is valid
        await updateChildMonthlyExpenditures(childId, amount);
        print(
            "✅ Payment of $amount successfully deducted from parent wallet: $parentId");
      } else if (success) {
        print(
            "✅ Payment of $amount successfully deducted from parent wallet: $parentId (no child ID provided)");
      } else {
        print("❌ Failed to deduct payment from parent wallet: $parentId");
      }

      return success;
    } catch (e) {
      print("❌ Error deducting payment from parent wallet: $e");
      return false;
    }
  }

  // Update child's monthly expenditures
  Future<void> updateChildMonthlyExpenditures(
      String childId, double amount) async {
    try {
      // First, check if we're using the document ID or the childId field
      print(
          "🔍 Attempting to update monthly expenditures for child: $childId with amount: $amount");

      // Try to find the document by querying for the childId field
      QuerySnapshot querySnapshot = await _firestore
          .collection('parentsChildren')
          .where('childId', isEqualTo: childId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Use the first matching document
        String docId = querySnapshot.docs.first.id;
        double currentExpenditures = (querySnapshot.docs.first.data()
                as Map<String, dynamic>)['monthlyExpenditures'] ??
            0.0;
        double newExpenditures = currentExpenditures + amount;

        await _firestore.collection('parentsChildren').doc(docId).update({
          'monthlyExpenditures': newExpenditures,
          'lastUpdated': DateTime.now().toIso8601String()
        });

        print(
            "✅ Child document with childId=$childId updated. Doc ID: $docId, New expenditures: $newExpenditures");
      } else {
        // Try direct document reference as fallback
        DocumentReference childRef =
            _firestore.collection('parentsChildren').doc(childId);
        DocumentSnapshot childDoc = await childRef.get();

        if (childDoc.exists) {
          double currentExpenditures = (childDoc.data()
                  as Map<String, dynamic>)['monthlyExpenditures'] ??
              0.0;
          double newExpenditures = currentExpenditures + amount;

          await childRef.update({
            'monthlyExpenditures': newExpenditures,
            'lastUpdated': DateTime.now().toIso8601String()
          });

          print(
              "✅ Child document with ID=$childId updated. New expenditures: $newExpenditures");
        } else {
          print("❌ Child document not found with ID or childId: $childId");
        }
      }
    } catch (e) {
      print("❌ Error updating child monthly expenditures: $e");
    }
  }

  // Method to get delivered orders for a specific date range without requiring complex index
  Future<List<ParentsAddChildren>> getDeliveredOrdersForDateRange(
      String cafeteriaName, String startDateStr, String endDateStr) async {
    try {
      print(
          "📅 Fetching delivered orders from $startDateStr to $endDateStr for cafeteria: $cafeteriaName");

      // Use a simpler query that requires fewer indexes
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('orderPreparation')
          .where('cafeteriaName', isEqualTo: cafeteriaName)
          .where('delivered', isEqualTo: true)
          .get();

      print(
          "📦 Fetched ${snapshot.docs.length} total delivered orders for cafeteria");

      // Filter the results in memory instead of in the query
      List<ParentsAddChildren> orders = [];
      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data();

          // Check status
          if (data['status'] != 'Delivered') {
            continue;
          }

          // Check delivery time
          String? deliveryTime = data['orderDeliveredTime'];
          if (deliveryTime == null) {
            continue;
          }

          // Check if within date range
          if (deliveryTime.compareTo(startDateStr) < 0 ||
              deliveryTime.compareTo(endDateStr) > 0) {
            continue;
          }

          // If we got here, the order matches all our criteria
          orders.add(ParentsAddChildren.fromJson(data));
        } catch (e) {
          print("❌ Error parsing order data: $e");
        }
      }

      // Sort the results manually (descending by delivery time)
      orders.sort((a, b) {
        String timeA = a.orderDeliveredTime ?? '';
        String timeB = b.orderDeliveredTime ?? '';
        return timeB.compareTo(timeA); // Descending order
      });

      print(
          "📦 Filtered to ${orders.length} delivered orders within date range");
      return orders;
    } catch (e) {
      print("❌ Error fetching delivered orders for date range: $e");

      // Try an even simpler approach if the first one fails
      try {
        print("🔄 Trying alternative approach to fetch orders");

        // Just get all orders for the cafeteria
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('orderPreparation')
            .where('cafeteriaName', isEqualTo: cafeteriaName)
            .get();

        List<ParentsAddChildren> orders = [];
        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data();

            // Apply all filters in memory
            if (data['delivered'] != true || data['status'] != 'Delivered') {
              continue;
            }

            String? deliveryTime = data['orderDeliveredTime'];
            if (deliveryTime == null) {
              continue;
            }

            if (deliveryTime.compareTo(startDateStr) < 0 ||
                deliveryTime.compareTo(endDateStr) > 0) {
              continue;
            }

            orders.add(ParentsAddChildren.fromJson(data));
          } catch (e) {
            print("❌ Error parsing order data: $e");
          }
        }

        // Sort manually
        orders.sort((a, b) {
          String timeA = a.orderDeliveredTime ?? '';
          String timeB = b.orderDeliveredTime ?? '';
          return timeB.compareTo(timeA);
        });

        print("📦 Alternative approach found ${orders.length} orders");
        return orders;
      } catch (fallbackError) {
        print("❌ Alternative approach also failed: $fallbackError");
        return [];
      }
    }
  }
}
