import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/base_service.dart';

class AdminProfileUpdateService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      DocumentSnapshot doc = await _firestore
          .collection("users")
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("❌ Error fetching profile: $e");
      return null;
    }
  }

  Future<bool> updateAdminProfile({
    required String cafeteriaName,
    File? newImageFile,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      Map<String, dynamic> updateData = {
        'cafeteriaName': cafeteriaName,
        'profileUpdatedAt': FieldValue.serverTimestamp(),
      };

      if (newImageFile != null) {
        String imageUrl = await uploadImage(newImageFile, "cafeteria_profile", userId);
        updateData['cafeteriaLogo'] = imageUrl;
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