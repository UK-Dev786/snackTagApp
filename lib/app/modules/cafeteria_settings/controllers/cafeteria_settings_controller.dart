import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, FirebaseFirestore, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CafeteriaSettingsController extends GetxController {
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
    Future<void> deleteAccount() async {
    try {
      isLoading.value = true;  // Start loading
      final user = _auth.currentUser;
      if (user != null) {
        // Check and delete staff data if exists
        QuerySnapshot staffDocs = await FirebaseFirestore.instance
            .collection('staffData')
            .where('userId', isEqualTo: user.uid)
            .get();
        
        if (staffDocs.docs.isNotEmpty) {
          print("Deleting ${staffDocs.docs.length} staff documents");
          for (var doc in staffDocs.docs) {
            await doc.reference.delete();
          }
        }

        // Check and delete meals data if exists
        QuerySnapshot mealDocs = await FirebaseFirestore.instance
            .collection('meals')
            .where('userId', isEqualTo: user.uid)
            .get();
            
        if (mealDocs.docs.isNotEmpty) {
          print("Deleting ${mealDocs.docs.length} meal documents");
          for (var doc in mealDocs.docs) {
            await doc.reference.delete();
          }
        }

        // Check and delete meal schedules if exists
        QuerySnapshot mealScheduleDocs = await FirebaseFirestore.instance
            .collection('meal_schedules')
            .where('userId', isEqualTo: user.uid)
            .get();
            
        if (mealScheduleDocs.docs.isNotEmpty) {
          print("Deleting ${mealScheduleDocs.docs.length} meal schedule documents");
          for (var doc in mealScheduleDocs.docs) {
            await doc.reference.delete();
          }
        }

        // Check and delete order preparations if exists
        QuerySnapshot orderPrepDocs = await FirebaseFirestore.instance
            .collection('orderPreparation')
            .where('cafeteriaId', isEqualTo: user.uid)
            .get();
            
        if (orderPrepDocs.docs.isNotEmpty) {
          print("Deleting ${orderPrepDocs.docs.length} order preparation documents");
          for (var doc in orderPrepDocs.docs) {
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
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;  // Stop loading regardless of success/failure
    }
  }
}
