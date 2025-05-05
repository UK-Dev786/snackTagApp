import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/routes/app_pages.dart';
import 'Shared_preference/preferences.dart';
import 'base_service.dart';

class UserService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(UserModel user) async {
    try {
      String? userId = _auth.currentUser?.uid;
      final UserPreferences userPreferences = UserPreferences();

      if (userId == null) {
        throw Exception("User not authenticated");
      }

      final updatedUser = UserModel(
        userID: userId,
        phoneNumber: user.phoneNumber,
        role: user.role,
        userAccountCreatedTime: user.userAccountCreatedTime,
      );

      var snapshot = await getDocument(CollectionKey.USER_COLLECTION, userId);
      print("Parent exists or not: ${snapshot.exists}");

      if (!snapshot.exists) {
        print("Creating new document for user: $userId");
        await createDocument(
          CollectionKey.USER_COLLECTION,
          userId,
          updatedUser.toJson(),
        );
        await userPreferences.saveUserId(userId);
        return false; // New user created
      }

      // Only try to access data if snapshot exists
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        String? cafeteriaName = data['cafeteriaName'];
        String? cafeteriaLogo = data['cafeteriaLogo'];
        print("Existing document data - cafeteriaName: $cafeteriaName, cafeteriaLogo: $cafeteriaLogo");

        // Return true if either cafeteriaName or cafeteriaLogo exists
        return (cafeteriaName != null && cafeteriaLogo != null);
      }

      return false; // Default return for new users
    } catch (e) {
      print("Error in createUser: $e");
      // You might want to show a snackbar here
      Get.snackbar(
        "Error",
        "Failed to create user. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  Future<bool> addCafeteriaInfo(String name, String logo, String college) async {
    // Get the currently authenticated user's UID
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    var snapshot = await getDocument(CollectionKey.USER_COLLECTION, userId);

    var user = UserModel.fromJson(snapshot.data()!);

    user.cafeteriaName = name;
    user.cafeteriaLogo = logo;
    user.schoolName = college;

    await updateDocument(
      CollectionKey.USER_COLLECTION,
      userId,
      user.toJson(),
    );

    print('User Data 📈📈📈📈📈${user.toJson()}');

    Get.offAllNamed(Routes.CAFETERIA_LANDING_PAGE);

    return !snapshot.exists;
  }
}
