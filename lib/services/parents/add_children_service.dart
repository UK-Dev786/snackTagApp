import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_selected_meals.dart'
    show Schedule;
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/base_service.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';
import 'package:intl/intl.dart';

class AddChildrenService extends BaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Method to fetch unique school names
  Future<List<String>> getSchoolNames() async {
    try {
      print("Fetching school names from Firestore...");
      QuerySnapshot snapshot = await firestore.collection('users').get();

      print("Total documents in users collection: ${snapshot.docs.length}");

      // Debug: Print all documents to see what's available
      for (var doc in snapshot.docs) {
        print("User document: ${doc.id}, data: ${doc.data()}");
      }

      // Extract all school names from the documents
      List<String> schoolNames = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('schoolName') &&
            data['schoolName'] != null &&
            data['schoolName'].toString().isNotEmpty) {
          schoolNames.add(data['schoolName'].toString());
        }
      }

      // Remove duplicates by converting to a Set and back to a List
      schoolNames = schoolNames.toSet().toList();

      print("Filtered school names (${schoolNames.length}): $schoolNames");

      // Only add a default school if the list is empty
      if (schoolNames.isEmpty) {
        schoolNames = ["Test School"];
        print("Added default test school since no schools were found");
      }

      return schoolNames;
    } catch (e) {
      print("Error fetching school names: $e");
      // Return a default school even on error
      return ["Test School"];
    }
  }

  /// Fetch users where `schoolName` matches the given input
  Stream<List<UserModel>> getCafeteriaSchool(String schoolName) {
    print("Searching for cafeterias with school name: $schoolName");

    // Create a stream transformer to handle empty results
    return FirebaseFirestore.instance
        .collection("users")
        .where("schoolName", isEqualTo: schoolName)
        .where("role",
            isEqualTo:
                "cafeteriaAdmin") // Make sure we only get cafeteria admins
        .snapshots()
        .map((snapshot) {
      print("Found ${snapshot.docs.length} cafeterias for school: $schoolName");

      List<UserModel> cafeterias = snapshot.docs.map((doc) {
        print("Fetched cafeteria data: ${doc.data()}");
        return UserModel.fromJson(doc.data());
      }).toList();

      // If no cafeterias found, create a test cafeteria for this school
      if (cafeterias.isEmpty) {
        print("No cafeterias found for $schoolName, creating a test cafeteria");

        // Create a dummy cafeteria for testing
        UserModel testCafeteria = UserModel(
          userID: "test_cafeteria_id",
          phoneNumber: "+1234567890",
          role: "cafeteriaAdmin",
          cafeteriaName: "Test Cafeteria",
          schoolName: schoolName,
          cafeteriaLogo: "https://via.placeholder.com/150",
          userAccountCreatedTime: DateTime.now(),
        );

        cafeterias.add(testCafeteria);
      }

      return cafeterias;
    });
  }

  // Fetch all children for a specific parent ID
  Future<List<ParentsAddChildren>> fetchChildrenByParentId(
      String parentId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("parentsChildren")
          .where("parentId", isEqualTo: parentId)
          .get();

      List<ParentsAddChildren> childrenList = querySnapshot.docs
          .map((doc) => ParentsAddChildren.fromJson(doc.data()))
          .toList();

      return childrenList;
    } catch (e) {
      print("Error fetching children: $e");
      return [];
    }
  }

  Stream<List<MealModel>> getMealsByCafeteriaUser(String userId) {
    return FirebaseFirestore.instance
        .collection("meals")
        .where("userId", isEqualTo: userId) // ✅ Filter meals by userId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print("Fetched Meal: ${doc.data()}");
        return MealModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<List<MealSheduleModel>> getPMealShedule(
      String userId, String mealId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("meal_schedules")
          .where("userId", isEqualTo: userId)
          .where("mealId", isEqualTo: mealId)
          .get();

      List<MealSheduleModel> meals = querySnapshot.docs.map((doc) {
        print("Fetched Meal: ${doc.data()}");
        return MealSheduleModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return meals;
    } catch (e) {
      print("❌ Error fetching meal schedule: $e");
      return [];
    }
  }

  // ========= adding children =========
  /// **Add a Child to Firestore**
  Future<bool> addOrUpdateChild(
      ParentsAddChildren childData, String? imgUrl) async {
    print("[UpdatingChildrenMealData] Service: Starting addOrUpdateChild");
    print(
        "[UpdatingChildrenMealData] Service: Parent ID: ${childData.parentId}");
    print("[UpdatingChildrenMealData] Service: Child ID: ${childData.childId}");
    print(
        "[UpdatingChildrenMealData] Service: Image URL provided: ${imgUrl != null ? 'Yes' : 'No'}");

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query Firestore for an existing child
      print(
          "[UpdatingChildrenMealData] Service: Querying Firestore for existing child");
      QuerySnapshot querySnapshot = await firestore
          .collection('parentsChildren')
          .where('parentId', isEqualTo: childData.parentId)
          .where('childId', isEqualTo: childData.childId)
          .get();

      // Print all matched documents
      print(
          "[UpdatingChildrenMealData] Service: Found ${querySnapshot.docs.length} matching documents");
      for (var doc in querySnapshot.docs) {
        print("[UpdatingChildrenMealData] Service: Document ID: ${doc.id}");
        print("[UpdatingChildrenMealData] Service: Data: ${doc.data()}");
      }

      bool isNewOrder = querySnapshot.docs.isEmpty;
      print("[UpdatingChildrenMealData] Service: Is new order: $isNewOrder");

      String childId = "";

      if (querySnapshot.docs.isNotEmpty) {
        print(
            "[UpdatingChildrenMealData] Service: Child data exists, updating...");

        // Get the existing document ID
        String existingChildId = querySnapshot.docs.first.id;
        childId = existingChildId;
        print(
            "[UpdatingChildrenMealData] Service: Existing document ID: $existingChildId");

        DocumentReference childDocRef =
            firestore.collection('parentsChildren').doc(existingChildId);

        // If a new image is provided, upload it and update Firestore
        if (imgUrl != null && imgUrl.isNotEmpty) {
          print(
              "[UpdatingChildrenMealData] Service: New image provided, uploading...");
          File imageFile = File(imgUrl);
          String imageUrl = await uploadChildImage(imageFile,
              "parentsChildren/${childData.parentId}", existingChildId);

          print(
              "[UpdatingChildrenMealData] Service: Image uploaded, URL: ${imageUrl.isNotEmpty ? 'Success' : 'Failed'}");

          if (imageUrl.isNotEmpty) {
            childData.childImageUrl = imageUrl; // Store the new image URL
            print(
                "[UpdatingChildrenMealData] Service: Updated child image URL in data model");
          } else {
            print(
                "[UpdatingChildrenMealData] Service: WARNING: Image upload failed");
          }
        } else {
          print(
              "[UpdatingChildrenMealData] Service: No new image provided, keeping existing image");
        }

        // Update the existing child data
        print(
            "[UpdatingChildrenMealData] Service: Updating document in Firestore");
        print(
            "[UpdatingChildrenMealData] Service: Data to update: ${childData.toJson()}");

        await childDocRef.update(childData.toJson());
        print(
            "[UpdatingChildrenMealData] Service: Child updated successfully: $existingChildId");
      } else {
        print(
            "[UpdatingChildrenMealData] Service: Child does not exist, adding new child...");

        // Create a new document
        DocumentReference childRef =
            firestore.collection('parentsChildren').doc(childData.childId);
        // childData.id = childRef.id; // Assign Firestore-generated ID
        // childId = childRef.id;

        print(
            "[UpdatingChildrenMealData] Service: New document ID: ${childRef.id}");

        // If an image is provided, upload it
        if (imgUrl != null && imgUrl.isNotEmpty) {
          print(
              "[UpdatingChildrenMealData] Service: Image provided for new child, uploading...");
          File imageFile = File(imgUrl);
          String imageUrl = await uploadChildImage(
              imageFile, "parentsChildren/${childData.parentId}", childRef.id);

          print(
              "[UpdatingChildrenMealData] Service: Image uploaded, URL: ${imageUrl.isNotEmpty ? 'Success' : 'Failed'}");

          if (imageUrl.isNotEmpty) {
            childData.childImageUrl = imageUrl; // Store the image URL
            print(
                "[UpdatingChildrenMealData] Service: Set child image URL in data model");
          } else {
            print(
                "[UpdatingChildrenMealData] Service: WARNING: Image upload failed");
          }
        } else {
          print(
              "[UpdatingChildrenMealData] Service: No image provided for new child");
        }

        // Save new child data to Firestore
        print(
            "[UpdatingChildrenMealData] Service: Saving new child data to Firestore");
        print(
            "[UpdatingChildrenMealData] Service: Data to save: ${childData.toJson()}");

        await childRef.set(childData.toJson());
        print(
            "[UpdatingChildrenMealData] Service: New child added successfully: ${childRef.id}");
      }

      // If this is a new order, send notifications to cafeteria owner and staff
      if (isNewOrder &&
          childData.cafeteriaName != null &&
          childData.cafeteriaName!.isNotEmpty) {
        print(
            "[UpdatingChildrenMealData] Service: New order, sending notifications to cafeteria staff");
        print(
            "[UpdatingChildrenMealData] Service: Cafeteria name: ${childData.cafeteriaName}");
        print(
            "[UpdatingChildrenMealData] Service: Child name: ${childData.childName ?? 'a child'}");

        await _sendNotificationsToCafeteriaOwnerAndStaff(
          childData.cafeteriaName!,
          childData.childName ?? "a child",
          childId,
          childData.parentId ?? "",
        );

        print(
            "[UpdatingChildrenMealData] Service: Notifications sent successfully");
      } else {
        print(
            "[UpdatingChildrenMealData] Service: Not a new order or missing cafeteria name, skipping notifications");
      }

      print(
          "[UpdatingChildrenMealData] Service: addOrUpdateChild completed successfully");
      return true;
    } catch (e) {
      print(
          "[UpdatingChildrenMealData] Service: ERROR adding/updating child: $e");
      print(
          "[UpdatingChildrenMealData] Service: Stack trace: ${StackTrace.current}");
      return false;
    }
  }

  // Method to send notifications to cafeteria owner and staff
  Future<void> _sendNotificationsToCafeteriaOwnerAndStaff(
    String cafeteriaName,
    String childName,
    String orderId,
    String parentId,
  ) async {
    try {
      print(
          "🔔 Sending notifications to cafeteria owner and staff for cafeteria: $cafeteriaName");

      // Make sure we're not sending notifications to the parent
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == parentId) {
        print(
            "⚠️ Current user is the parent, ensuring notifications only go to cafeteria staff and admin");
      }

      // 1. Find the cafeteria owner (user with cafeteriaName matching)
      QuerySnapshot ownerSnapshot = await firestore
          .collection('users')
          .where('cafeteriaName', isEqualTo: cafeteriaName)
          .limit(1)
          .get();

      if (ownerSnapshot.docs.isEmpty) {
        print("⚠️ No cafeteria owner found for cafeteria: $cafeteriaName");
        return;
      }

      // Get the cafeteria owner's ID
      String cafeteriaOwnerId = ownerSnapshot.docs.first.id;
      print("✅ Found cafeteria owner with ID: $cafeteriaOwnerId");

      // Skip if owner is the current user (parent)
      if (cafeteriaOwnerId == currentUserId) {
        print(
            "⚠️ Cafeteria owner is the current user (parent), skipping owner notification");
      } else {
        // 2. Send notification to cafeteria owner
        final NotificationService notificationService = NotificationService();

        // Create notification for cafeteria owner
        final ownerNotification = {
          'userId': cafeteriaOwnerId,
          'title': 'New Order Received',
          'body': 'A new order has been placed for $childName',
          'type': 'new_order',
          'data': {
            'orderId': orderId,
            'childName': childName,
            'parentId': parentId,
            'notificationType': 'new_order',
          },
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        };

        // Save notification directly to Firestore for the owner
        await firestore
            .collection('users')
            .doc(cafeteriaOwnerId)
            .collection('notifications')
            .add(ownerNotification);

        // Also send FCM notification
        await notificationService.sendNotification(
          userId: cafeteriaOwnerId,
          title: 'New Order Received',
          body: 'A new order has been placed for $childName',
          type: 'new_order',
          data: {
            'orderId': orderId,
            'childName': childName,
            'parentId': parentId,
            'notificationType': 'new_order',
          },
        );
      }

      // Create a notification service instance
      final NotificationService notificationService = NotificationService();

      // 3. Find all staff associated with this cafeteria owner
      QuerySnapshot staffSnapshot = await firestore
          .collection('staffData')
          .where('userId', isEqualTo: cafeteriaOwnerId)
          .get();

      print(
          "✅ Found ${staffSnapshot.docs.length} staff members for cafeteria owner");

      // 4. Send notifications to all staff members
      for (var staffDoc in staffSnapshot.docs) {
        String staffId = staffDoc.id; // Use the document ID directly

        // Get staff data to ensure we have all the information
        Map<String, dynamic> staffData =
            staffDoc.data() as Map<String, dynamic>;
        print("Staff data: $staffData");

        // Make sure the staff has a document in the users collection
        DocumentSnapshot staffUserDoc =
            await firestore.collection('users').doc(staffId).get();

        if (!staffUserDoc.exists) {
          // Create a user document for this staff member if it doesn't exist
          await firestore.collection('users').doc(staffId).set({
            'userId': staffId,
            'role': 'staff',
            'isStaff': true,
            'staffName': staffData['staffName'] ?? 'Staff Member',
          }, SetOptions(merge: true));

          print("Created user document for staff member: $staffId");
        }

        // DO NOT update FCM token here - this would use the parent's token
        // Staff should register their own FCM token when they log in

        // Create notification for staff member
        final staffNotification = {
          'userId': staffId,
          'title': 'New Order Received',
          'body': 'A new order has been placed for $childName',
          'type': 'new_order',
          'data': {
            'orderId': orderId,
            'childName': childName,
            'parentId': parentId,
            'notificationType': 'new_order',
          },
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        };

        // Save notification directly to Firestore for the staff
        await firestore
            .collection('users')
            .doc(staffId)
            .collection('notifications')
            .add(staffNotification);

        // Also send FCM notification
        await notificationService.sendNotification(
          userId: staffId,
          title: 'New Order Received',
          body: 'A new order has been placed for $childName',
          type: 'new_order',
          data: {
            'orderId': orderId,
            'childName': childName,
            'parentId': parentId,
            'notificationType': 'new_order',
          },
        );

        print("✅ Notification sent to staff member: $staffId");
      }

      print("✅ All notifications sent successfully");
    } catch (e) {
      print("❌ Error sending notifications to cafeteria owner and staff: $e");
      // Don't rethrow to prevent disrupting the main flow
    }
  }

  Future<bool> addChildren(ParentsAddChildren childData, String? imgUrl) async {
    print(" Index out of range :  ,,,,uuuuuuue ${imgUrl}");
    File imageFile = File(imgUrl!);
    String imagePath = imageFile.path;
    print(" Index out of range :  ,,,,uuuuuuue ${imagePath}");

    try {
      String docId =
          FirebaseFirestore.instance.collection("parentsChildren").doc().id;
      // Assign the generated ID to the meal model
      childData.id = docId;
      // Upload image if available
      if (imageFile != null) {
        String imageUrl =
            await uploadChildImage(imageFile, "parentsChildren", docId);
        if (imageUrl.isNotEmpty) {
          childData.childImageUrl = imageUrl; // Store the URL in Firestore
        }
      }
      await createDocument("parentsChildren", docId, childData.toJson());
      return true; // Success
    } catch (e) {
      print("Error adding child: $e");
      return false; // Failure
    }
  }

  // ========= Update children against Parent id and child id =========
  Future<bool> updateChildren(String parentId, String childId,
      ParentsAddChildren childData, String? imgUrl) async {
    print("[UpdatingChildrenMealData] Service: Starting updateChildren");
    print("[UpdatingChildrenMealData] Service: Parent ID: $parentId");
    print("[UpdatingChildrenMealData] Service: Child ID: $childId");
    print("[UpdatingChildrenMealData] Service: Image URL: $imgUrl");

    try {
      // Reference to Firestore document
      print(
          "[UpdatingChildrenMealData] Service: Getting reference to document: $childId");
      DocumentReference childDocRef =
          FirebaseFirestore.instance.collection("parentsChildren").doc(childId);

      // Ensure meal data has scheduled dates
      if (childData.selectedMealMenuData != null) {
        for (var meal in childData.selectedMealMenuData!) {
          if (meal.schedule != null &&
              (meal.scheduledDates == null || meal.scheduledDates!.isEmpty)) {
            // Calculate scheduled dates if they're missing
            print(
                "[UpdatingChildrenMealData] Service: Recalculating scheduled dates for meal: ${meal.mealName}");
            List<String> scheduledDates =
                _calculateScheduledDates(meal.schedule!);
            meal.scheduledDates = scheduledDates;
            print(
                "[UpdatingChildrenMealData] Service: Calculated dates: ${meal.scheduledDates}");
          }
        }
      }

      // If a new image is provided, upload it and update the URL
      if (imgUrl != null && imgUrl.isNotEmpty) {
        print(
            "[UpdatingChildrenMealData] Service: New image provided, uploading...");

        // Check if the image URL is already a Firebase Storage URL
        if (imgUrl.startsWith('https://firebasestorage.googleapis.com')) {
          print(
              "[UpdatingChildrenMealData] Service: Image is already a Firebase Storage URL, skipping upload");
          childData.childImageUrl = imgUrl;
        } else {
          // It's a local file path, upload it
          print(
              "[UpdatingChildrenMealData] Service: Image is a local file path, uploading to Firebase Storage");
          File imageFile = File(imgUrl);

          // Check if file exists
          bool fileExists = await imageFile.exists();
          print("[UpdatingChildrenMealData] Service: File exists: $fileExists");

          if (fileExists) {
            String imageUrl = await uploadChildImage(
                imageFile, "parentsChildren/$parentId", childId);

            print(
                "[UpdatingChildrenMealData] Service: Image uploaded, URL: ${imageUrl.isNotEmpty ? imageUrl : 'Failed'}");

            if (imageUrl.isNotEmpty) {
              childData.childImageUrl = imageUrl;
              print(
                  "[UpdatingChildrenMealData] Service: Updated child image URL in data model");
            } else {
              print(
                  "[UpdatingChildrenMealData] Service: WARNING: Image upload failed");
            }
          } else {
            print(
                "[UpdatingChildrenMealData] Service: WARNING: Image file does not exist at path: $imgUrl");
          }
        }
      } else {
        print("[UpdatingChildrenMealData] Service: No new image provided");
      }

      // Update Firestore document
      print("[UpdatingChildrenMealData] Service: Updating Firestore document");
      print(
          "[UpdatingChildrenMealData] Service: Data to update: ${childData.toJson()}");

      await childDocRef.update(childData.toJson());

      print("[UpdatingChildrenMealData] Service: Child updated successfully");
      return true;
    } catch (e) {
      print("[UpdatingChildrenMealData] Service: ERROR updating child: $e");
      print(
          "[UpdatingChildrenMealData] Service: Stack trace: ${StackTrace.current}");
      return false;
    }
  }

  /// Calculates the scheduled dates for a meal based on its schedule configuration.
  List<String> _calculateScheduledDates(Schedule schedule) {
    List<String> scheduledDates = [];
    DateTime today = DateTime.now();

    // Default to 1 if repeatCount is null or empty
    int repeatCount = int.tryParse(schedule.repeatCount ?? '1') ?? 1;

    // Get the repeat days
    List<String> repeatDays = schedule.repeatOn ?? [];
    if (repeatDays.isEmpty) {
      print("[CalculateScheduledDates] No repeat days specified");
      return scheduledDates;
    }

    // Convert day names to lowercase for case-insensitive comparison
    List<String> lowerCaseRepeatDays =
        repeatDays.map((day) => day.toLowerCase()).toList();

    // Calculate end date based on repeat frequency
    DateTime endDate;
    if (schedule.repeatEvery == 'week') {
      endDate = today.add(Duration(days: 7 * repeatCount));
    } else if (schedule.repeatEvery == 'month') {
      // Approximate a month as 30 days for simplicity
      endDate = today.add(Duration(days: 30 * repeatCount));
    } else {
      // Default to 1 week if repeatEvery is invalid
      endDate = today.add(Duration(days: 7));
    }

    // Loop through each day from today to end date
    for (DateTime date = today;
        date.isBefore(endDate);
        date = date.add(Duration(days: 1))) {
      // Get the day name for the current date
      String dayName = DateFormat('EEEE').format(date).toLowerCase();

      // Check if this day is in the repeat days
      if (lowerCaseRepeatDays.contains(dayName)) {
        // Add this date to the scheduled dates
        scheduledDates.add(DateFormat('dd-MM-yyyy').format(date));
      }
    }

    return scheduledDates;
  }

  //FOR DELETING ALL CHILDREN ON THE BASE  ARE CHILDREN ARE IN SAME SCHOOL(OF YES OR NO)
  Future<bool> deleteChildrenByParentId(String parentId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get all children where parentId matches
      QuerySnapshot querySnapshot = await firestore
          .collection('parentsChildren')
          .where('parentId', isEqualTo: parentId)
          .get();

      // Delete each document found
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await firestore.collection('parentsChildren').doc(doc.id).delete();
      }

      print("All children deleted for parent ID: $parentId");
      return true; // Success
    } catch (e) {
      print("Error deleting children: $e");
      return false; // Failure
    }
  }
}
