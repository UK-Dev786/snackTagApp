import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/staff/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart'; // Import for Completer

class AuthenticationService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserPreferences userPreferences = UserPreferences();

  // Handle phone number authentication
  Future<Result> authenticatePhoneNumber(String phoneNumber) async {
    final Completer<Result> completer = Completer<Result>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!completer.isCompleted) {
            try {
              await _auth.signInWithCredential(credential);
              completer
                  .complete(Result.success(message: "Verification completed"));
            } catch (e) {
              completer
                  .complete(Result.error("Failed to sign in with credentials"));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer
                .complete(Result.error(e.message ?? "Verification failed"));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(Result.success(
                message: "Code sent", verificationId: verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(Result.success(
                message: "Timeout", verificationId: verificationId));
          }
        },
      );

      return completer.future;
    } catch (e) {
      return Result.error("An error occurred. Please try again.");
    }
  }

  // Verify OTP and complete the authentication
  Future<Result> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      return Result.success(message: "OTP verification successful");
    } catch (e) {
      return Result.error("Invalid OTP. Please try again.");
    }
  }
  Future<StaffModel?> staffLogin(String number, String password) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await firestore
          .collection("staffData")
          .where("staffPhone", isEqualTo: number)
          .where("staffPassword", isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var staffData = snapshot.docs.first.data() as Map<String, dynamic>;
        String staffId = snapshot.docs.first.id;
        userPreferences.saveUserId(staffId);

        final newStaffData = StaffModel(
          id: staffId,
          staffName: staffData["staffName"],
          staffPhone: staffData["staffPhone"],
            staffPassword: staffData["staffPassword"],
            staffEmail:staffData["staffEmail"],
            userId:staffData["userId"],
            imageUrl: staffData["imageUrl"]
        );

        await userPreferences.saveStaffDataPreference(newStaffData);
        return StaffModel.fromMap(staffId, staffData);
      } else {
        print("Invalid phone number or password");
        return null; // Return null when credentials are incorrect
      }
    } catch (e) {
      print("Error during login: $e");
      return null; // Return null in case of an error
    }
  }


  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    return await isDocumentExists("staffData", "staffPhone", phoneNumber);
  }
  // Check if a document with a specific field value exists
  Future<bool> isDocumentExists(String collectionPath, String field, String value) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      var querySnapshot = await firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if document exists
    } catch (e) {
      print("Error checking document: $e");
      return false; // Assume not found in case of error
    }
  }

}

class Result {
  final bool success;
  final String message;
  final String? verificationId;

  Result.success({this.message = 'Success', this.verificationId})
      : success = true;
  Result.error(this.message)
      : success = false,
        verificationId = null;
}
