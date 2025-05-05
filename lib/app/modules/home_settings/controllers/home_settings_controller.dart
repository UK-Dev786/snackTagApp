import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeSettingsController extends GetxController {
  // Reactive variable for the selected index
  var selectedIndex = 0.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;  // Add loading state variable

  Future<void> logout() async {
    try {
      await _auth.signOut();
      removeUserId();
      Get.offAllNamed(Routes.SPLASH); // Navigate to the Splash Screen
    } catch (e) {
      Get.snackbar("Error", "Failed to log out. Please try again.");
    }
  }
  Future<void> removeUserId() async {
    UserPreferences preferences = UserPreferences();
    preferences.removeUserId();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }
  // Method to update the selected index
  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;  // Start loading
      final user = _auth.currentUser;
      if (user != null) {
        // Check and delete children data if exists
        QuerySnapshot childrenDocs = await FirebaseFirestore.instance
            .collection('parentsChildren')
            .where('parentId', isEqualTo: user.uid)
            .get();
        
        if (childrenDocs.docs.isNotEmpty) {
          print("Deleting ${childrenDocs.docs.length} children documents");
          for (var doc in childrenDocs.docs) {
            await doc.reference.delete();
          }
        }

        // Check and delete wallet data if exists
        QuerySnapshot walletDocs = await FirebaseFirestore.instance
            .collection('ParentWalletAmount')
            .where('parentId', isEqualTo: user.uid)
            .get();
            
        if (walletDocs.docs.isNotEmpty) {
          print("Deleting ${walletDocs.docs.length} wallet documents");
          for (var doc in walletDocs.docs) {
            await doc.reference.delete();
          }
        }

        // Check if user document exists before deleting
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          print("Deleting user document");
          await userDoc.reference.delete();
        }

        // Clear local storage
        await removeUserId();
        
        // Delete the Firebase Auth account
        await user.delete();
        
        await Future.delayed(const Duration(seconds: 2)); // Add delay before navigation
        
        // Navigate to splash screen after successful deletion
        Get.offAllNamed(Routes.SPLASH);
      }
    } catch (e) {
      print("Delete account error: $e");
      Get.snackbar(
        "Error", 
        "Failed to delete account. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;  // Stop loading regardless of success/failure
    }
  }
}
