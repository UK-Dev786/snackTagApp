import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/authentication_service.dart';
import 'package:snacktag/services/parent_authentication-service.dart';
import 'package:snacktag/services/parents/parenents_services.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';
// // import 'package:snacktag/app/routes/app_routes.dart';

import '../../../../config/app_const.dart';

class PhoneVerificationController extends GetxController {
  final otpController = ''.obs; // Observable for OTP
  final isLoading = false.obs;

  final ParentAuthenticationService _authService =
      ParentAuthenticationService();
  final ParentsServices _parentsService = ParentsServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String phoneNumber;
  final String verificationId;
  PhoneVerificationController(
      {required this.phoneNumber, required this.verificationId});
  @override
  void onInit() {
    super.onInit();
    // You can now use verificationId and phoneNumber in your controller
    print('Verification ID: $verificationId');
    print('Phone Number: $phoneNumber');
  }

  // Handle OTP verification
  Future<void> verifyOTP() async {
    if (otpController.value.isEmpty || otpController.value.length < 6) {
      showCustomSnack("Please enter a valid OTP");
      return;
    }

    try {
      isLoading.value = true;

      // Call the service for OTP verification
      final result =
          await _authService.verifyOTP(verificationId, otpController.value);

      if (result.success) {
        final user = UserModel(
          phoneNumber: phoneNumber,
          role: 'parents',
          userAccountCreatedTime: DateTime.now(),
        );
        bool newParentsCreated = await _parentsService.createUser(user);
        final currentUser = _auth.currentUser;
        final id = currentUser?.uid;

        // Fetch user document from Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
            .collection(CollectionKey.USER_COLLECTION)
            .doc(id)
            .get();
        final parentName = userDoc.data()?['parentsName'] as String?;
        print('Current User Id : $id');
        print('Current parent name  : $parentName');
        bool isWalletExist = await doesParentWalletExist(id!);
        bool isChildExist = await doesParentHaveChildren(id);
        // Get.offAllNamed(Routes.LANDING_PAGE);
        // if (newParentsCreated) {
        //   print("Add New parent  ${user.schoolName}");
        //
        //   Get.toNamed(Routes.PARENT_PROFILE);
        // } else {
        //   print("parent already exist");
        //   Get.offAllNamed(Routes.LANDING_PAGE);
        // }
        // Navigate to home screen
        if (parentName == null) {
          return Get.offNamed(Routes.PARENT_PROFILE);
        } else if (isWalletExist == true) {
          return Get.offNamed(Routes.PARENTS_ADD_WALLET);
        } else if (isChildExist == true) {
          return Get.offNamed(Routes.PARENTS_CHILDREN_DETAILS);
        }
        return Get.offNamed(Routes.LANDING_PAGE);
      } else {
        showCustomSnack(result.message); // Show the error message
      }
    } finally {
      isLoading.value = false;
    }
  }

  // FOR CHECK THE PARENTS HAVE WALLET OR NOT
  Future<bool> doesParentWalletExist(String userId) async {
    QuerySnapshot<Map<String, dynamic>> walletSnapshot = await _firestore
        .collection(CollectionKey.USER_COLLECTION)
        .doc(userId) // Reference to the user document
        .collection("ParentWalletAmount") // Reference to the subcollection
        .limit(1) // Fetch at most one document (for efficiency)
        .get();
    // If there are documents in the subcollection, return true
    return walletSnapshot.docs.isEmpty;
  }

// FOR CHECK THE PARENTS HAVE CHILDREN OR NOT
  Future<bool> doesParentHaveChildren(String parentId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection("parentsChildren") // Collection Name
            .where("parentId", isEqualTo: parentId) // Filter by parentId
            .limit(1) // Optimize query to check only one document
            .get();

    return querySnapshot
        .docs.isEmpty; // Returns true if at least one document exists
  }
}
