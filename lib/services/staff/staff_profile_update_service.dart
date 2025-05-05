import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/base_service.dart';

class StaffProfileUpdateService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update staff profile data
  Future<bool> updateStaffProfile({
    required String staffId,
    required String staffName,
    File? profileImage,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'staffName': staffName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Upload image if provided
      if (profileImage != null) {
        String imageUrl = await uploadImage(
          profileImage,
          "staffData",
          staffId,
        );
        updateData['imageUrl'] = imageUrl;
      }
      print("staff id off : ${staffId}");
      // Update staff data in Firestore
      await _firestore.collection("staffData").doc(staffId).update(updateData);

      // Fetch updated document to return the new image URL
      DocumentSnapshot<Map<String, dynamic>> updatedDoc =
          await _firestore.collection("staffData").doc(staffId).get();

      return true;
    } catch (e) {
      print("❌ Error updating staff profile: $e");
      return false;
    }
  }
  // Future<StaffModel?> getStaffData(String staffId) async {
  //   try {
  //     DocumentSnapshot<Map<String, dynamic>> doc =
  //         await _firestore.collection("staffData").doc(staffId).get();
  //
  //     if (!doc.exists) {
  //       print("⚠️ No staff data found for ID: $staffId");
  //       return null;
  //     }
  //
  //     return StaffModel.fromMap(doc.data()!);
  //   } catch (e) {
  //     print("❌ Error fetching staff data: $e");
  //     return null;
  //   }
  // }

  /// Fetch admin data using staff's userId
  Future<UserModel?> getAdminData(String adminUserId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection("users").doc(adminUserId).get();

      if (!doc.exists) {
        print("⚠️ No admin data found for ID: $adminUserId");
        return null;
      }

      print("📍 Fetched admin data: ${doc.data()}");
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print("❌ Error fetching admin data: $e");
      throw Exception("Failed to fetch admin data: $e");
    }
  }
}
