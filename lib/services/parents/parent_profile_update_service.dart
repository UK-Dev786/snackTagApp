import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/base_service.dart';

class ParentProfileUpdateService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      DocumentSnapshot<Map<String, dynamic>> doc = 
          await _firestore.collection("users").doc(userId).get();

      if (!doc.exists) {
        print("⚠️ No user profile found for ID: $userId");
        return null;
      }

      print("📍 Fetched user profile data: ${doc.data()}");
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print("❌ Error fetching user profile: $e");
      throw Exception("Failed to fetch user profile: $e");
    }
  }

  // Update parent profile
  Future<bool> updateParentProfile({
    required String parentName,
    String? profileImage,
    File? newImageFile,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      Map<String, dynamic> updateData = {
        'parentsName': parentName,
        'profileUpdatedAt': FieldValue.serverTimestamp(),
      };

      // If new image file is provided, upload it
      if (newImageFile != null) {
        String imageUrl = await uploadImage(newImageFile, "parents_profile", userId);
        updateData['parentsPic'] = imageUrl;
      }

      await _firestore
          .collection("users")
          .doc(userId)
          .update(updateData);

      print("✅ Profile updated successfully");
      return true;
    } catch (e) {
      print("❌ Error updating profile: $e");
      return false;
    }
  }
}