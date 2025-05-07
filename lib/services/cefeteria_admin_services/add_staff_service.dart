import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/base_service.dart';

class AddStaffService extends BaseService {
  Future<void> addStaff(
      StaffModel staff, File? imageFile, String userId) async {
    print("📌 Service: Adding staff for user ID: $userId");

    // Create a reference to the new staff document in the user's staffData subcollection
    DocumentReference staffDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("staffData")
        .doc();

    // Assign the generated ID to the staff model
    String docId = staffDocRef.id;
    staff.id = docId;

    print("📌 Service: Generated staff document ID: $docId");

    // Upload image if available
    if (imageFile != null) {
      print("📌 Service: Uploading staff profile image");
      staff.imageUrl = await uploadImage(imageFile, "staffProfile", docId);
      print("📌 Service: Image uploaded, URL: ${staff.imageUrl}");
    }

    // Save Staff Data to Firestore
    print("📌 Service: Saving staff data to Firestore ${staff}");
    await staffDocRef.set(staff.toMap());
    print("✅ Service: Staff data saved successfully");
  }

// Fetch the staff Data
  Stream<List<StaffModel>> fetchStaffData(String userId) {
    print("📌 Service: Fetching staff data for user ID: $userId");

    return FirebaseFirestore.instance
        .collection("staffData")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print("sss#ll ${doc.data()}");
        return StaffModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Delete the Staff Data
  Future<void> deleteStaffData(String staffId) async {
    await deleteDocument("staffData", staffId);
    // await deleteStorage("staffData", staffId);
  }

  // Check if phone number already exists
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    return await isDocumentExists("staffData", "staffPhone", phoneNumber);
  }

  // Check if email already exists
  Future<bool> isEmailExists(String email) async {
    print("[AddStaffScreen] Service: Checking if email exists: $email");
    return await isDocumentExists("staffData", "staffEmail", email);
  }

  Future<void> editStaffData(
      String userId, String staffId, Map<String, dynamic> data) async {
    await editDocuments("staffData", staffId, userId, data);
  }

  /// ✅ Update staff data with user verification
  Future<bool> updateStaff(String staffId, String userId,
      StaffModel updatedStaff, Map<String, dynamic> data) async {
    try {
      // await editDocuments(
      //   "staffData", // Collection name
      //   staffId, // Document ID
      //   userId,  // User ID for verification
      //   updatedStaff.toMap(), // Data to update
      // );
      await editStaffDocuments(staffId, userId, "staffData", data);
      return true;
    } catch (e) {
      print("❌ Error updating staff: $e");
      return false;
    }
  }
}
