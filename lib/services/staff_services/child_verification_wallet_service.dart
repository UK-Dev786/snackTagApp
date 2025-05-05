import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';
import 'package:snacktag/services/base_service.dart';

class ChildVerificationWalletService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ParentAddWalletModel?> fetchChildParentWallet(String parentId) async {
    try {
      // Get the parent's wallet document
      final walletSnapshot = await _firestore
          .collection('users')
          .doc(parentId)
          .collection('ParentWalletAmount')
          .limit(1) // Get the first document in the collection
          .get();

      if (walletSnapshot.docs.isEmpty) {
        print("No wallet found for parent: $parentId");
        return null;
      }

      DocumentSnapshot firstDoc = walletSnapshot.docs.first;
      return ParentAddWalletModel.fromJson(
        firstDoc.id,
        firstDoc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      print("Error fetching parent wallet: $e");
      throw Exception("Failed to fetch parent wallet: $e");
    }
  }

  Future<bool> saveOrderPreparation(ParentsAddChildren childData,
      String staffName, String cafeteriaId) async {
    try {
      // Create new document in orderPreparation collection
      DocumentReference orderPrepRef =
          _firestore.collection('orderPreparation').doc();

      Map<String, dynamic> orderPrepData = {
        'orderPrepId': orderPrepRef.id,
        'childId': childData.childId,
        'parentId': childData.parentId,
        'childName': childData.childName,
        'schoolName': childData.schoolName,
        'cafeteriaName': childData.cafeteriaName,
        'selectedMealMenuData': childData.selectedMealMenuData
            ?.map((meal) => meal.toMap())
            .toList(),
        'startPreparation': true,
        'delivered': false,
        'allChildrenAreInSameSchool': childData.allChildrenAreInSameSchool,
        'date': childData.date,
        'status': 'in_preparation',
        'orderPreparationDate': DateTime.now().toIso8601String(),
        'numberOfChildren': childData.numberOfChildren,
        'classroomDelivery': childData.classroomDelivery,
        'childSchoolID': childData.childSchoolID,
        'childImageUrl': childData.childImageUrl,
        'orderPreparedBy': staffName,
        'cafeteriaId': cafeteriaId,
      };

      print("📝 Saving Order Preparation Data:");
      print(orderPrepData);

      await orderPrepRef.set(orderPrepData);
      print("✅ Order preparation document created with ID: ${orderPrepRef.id}");

      return true;
    } catch (e) {
      print("❌ Error saving order preparation: $e");
      return false;
    }
  }

  // Get the latest order preparation for a child
  Future<ParentsAddChildren?> getLatestOrderPreparation(String childId) async {
    try {
      // Query the orderPreparation collection for the latest document for this child
      // First try with a simpler query to avoid index issues
      final querySnapshot = await _firestore
          .collection('orderPreparation')
          .where('childId', isEqualTo: childId)
          .orderBy('orderPreparationDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No order preparation found for child: $childId");
        return null;
      }

      // Get the first (most recent) document
      DocumentSnapshot doc = querySnapshot.docs.first;
      return ParentsAddChildren.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error fetching latest order preparation: $e");
      // If there's an error (possibly due to missing index), try a simpler approach
      try {
        // Fallback to a simpler query without ordering
        final simpleQuerySnapshot = await _firestore
            .collection('orderPreparation')
            .where('childId', isEqualTo: childId)
            .limit(10)
            .get();

        if (simpleQuerySnapshot.docs.isEmpty) {
          return null;
        }

        // Sort manually
        final docs = simpleQuerySnapshot.docs;
        docs.sort((a, b) {
          final dateA = a.data()['orderPreparationDate'] as String? ?? '';
          final dateB = b.data()['orderPreparationDate'] as String? ?? '';
          return dateB.compareTo(dateA); // Descending order
        });

        return ParentsAddChildren.fromJson(docs.first.data());
      } catch (fallbackError) {
        print("Fallback query also failed: $fallbackError");
        return null; // Return null instead of throwing to avoid app crashes
      }
    }
  }

  // Check if an order has already been prepared for a child today
  Future<bool> isOrderAlreadyPreparedToday(String childId) async {
    try {
      // Get today's date at midnight (start of the day)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Convert to ISO string format for Firestore query
      final startOfDayStr = startOfDay.toIso8601String();
      final endOfDayStr = endOfDay.toIso8601String();

      print("Checking for orders between $startOfDayStr and $endOfDayStr");

      // Query for any orders prepared today for this child
      final querySnapshot = await _firestore
          .collection('orderPreparation')
          .where('childId', isEqualTo: childId)
          .where('orderPreparationDate', isGreaterThanOrEqualTo: startOfDayStr)
          .where('orderPreparationDate', isLessThan: endOfDayStr)
          .get();

      // If any documents are found, an order has already been prepared today
      final orderExists = querySnapshot.docs.isNotEmpty;

      if (orderExists) {
        print("Found existing order preparation for child $childId today");
      } else {
        print("No existing order preparation found for child $childId today");
      }

      return orderExists;
    } catch (e) {
      print("Error checking for existing order preparation: $e");

      // Fallback approach if the compound query fails
      try {
        // Get all orders for this child
        final simpleQuerySnapshot = await _firestore
            .collection('orderPreparation')
            .where('childId', isEqualTo: childId)
            .get();

        if (simpleQuerySnapshot.docs.isEmpty) {
          return false;
        }

        // Get today's date at midnight (start of the day)
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        // Manually filter for orders prepared today
        for (var doc in simpleQuerySnapshot.docs) {
          final prepDateStr =
              doc.data()['orderPreparationDate'] as String? ?? '';
          if (prepDateStr.isNotEmpty) {
            try {
              final prepDate = DateTime.parse(prepDateStr);
              if (prepDate.isAfter(startOfDay) && prepDate.isBefore(endOfDay)) {
                print(
                    "Found existing order preparation for child $childId today (manual check)");
                return true;
              }
            } catch (parseError) {
              print("Error parsing date: $parseError");
            }
          }
        }

        print(
            "No existing order preparation found for child $childId today (manual check)");
        return false;
      } catch (fallbackError) {
        print("Fallback query also failed: $fallbackError");
        return false; // Default to false to avoid blocking legitimate orders
      }
    }
  }
}
