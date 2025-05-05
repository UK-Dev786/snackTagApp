import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserPreferences preferences = UserPreferences();
  @override
  void onInit() {
    super.onInit();
    checkUserStatus();
  }


  Future<void> checkUserStatus() async {
    StaffModel? staffModel = await preferences.getStaffDataPreference();

    await Future.delayed(const Duration(seconds: 3)); // Delay for splash screen

    final user = _auth.currentUser;
    print("user value is on splash ${user?.phoneNumber}");
    // ========== Staff  Flow ==========

    if (user == null) {
      // No user logged in, navigate to selection screen
      // CHECK THE STAFF IS LOGGED IN OR NOT
      if (staffModel != null) {
        Get.offAllNamed(Routes.STAFF_LANDING_PAGE);
        return;
      }
      Get.offNamed(Routes.SELECTION);
      return;
    }
    // ========== Staff  Flow  End==========

    // Fetch user document from Firestore
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection(CollectionKey.USER_COLLECTION).doc(user.uid).get();
    print("user value documents splash ${userDoc.exists}");

    if (!userDoc.exists) {
      Get.offNamed(Routes.SELECTION);
      return;
    }

    final role = userDoc.data()?['role'] as String?;
    final cafaeteriaName = userDoc.data()?['cafeteriaName'] as String?;
    final schoolName = userDoc.data()?['schoolName'] as String?;
    final parentName = userDoc.data()?['parentsName'] as String?;

    print("rolllllll  ${role} cafateria Name  ${cafaeteriaName} school name  ${schoolName} parent name  ${parentName}");

    // ========== Cafeteria  Flow ==========

    if (role == "cafeteriaAdmin") {
      if (cafaeteriaName == null) {
        return Get.offNamed(Routes.CAFETERIA_DETAIL);
      }
      return Get.offNamed(Routes.CAFETERIA_LANDING_PAGE);
    }
    // ========== Parent Flow ==========
    else if (role == "parents") {
      // Fetch Parent Wallet  document from Firestore
      bool isWalletExist = await doesParentWalletExist(user.uid);
      bool isChildExist = await doesParentHaveChildren(user.uid);

      print("user value documents splash adfa ${isChildExist}");
      if (parentName == null) {
        return Get.offNamed(Routes.PARENT_PROFILE);
      } else if (isWalletExist == true) {
        return Get.offNamed(Routes.PARENTS_ADD_WALLET);
      } else if (isChildExist == true) {
        return Get.offNamed(Routes.PARENTS_CHILDREN_DETAILS);
      }
      return Get.offNamed(Routes.LANDING_PAGE);
    }
    // ========== Selection Flow ==========
    else {
      return Get.offNamed(Routes.SELECTION);
    }

    //
    // // // CHECK THE PARENTS PROFILE COMPLETED OR NOT
    // // if (userDoc.data() != null && userDoc.data()!.containsKey('parentsName') && role == "parents") {
    // //  return Get.offNamed(Routes.PARENT_PROFILE);
    // // }
    //
    //
    //
    //
    // if (role == null) {
    //   Get.offNamed(Routes.SELECTION);
    //   return;
    // }
    //
    // // Navigate based on user role
    // switch (role) {
    //   case 'cafeteriaStaff':
    //     Get.offNamed(Routes.STAFF_LANDING_PAGE);
    //     break;
    //   case 'cafeteriaAdmin':
    //     Get.offNamed(Routes.CAFETERIA_LANDING_PAGE);
    //     break;
    //   case 'parents':
    //     Get.offNamed(Routes.LANDING_PAGE);
    //     break;
    //   default:
    //     Get.offNamed(Routes.SELECTION);
    // }
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
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection("parentsChildren") // Collection Name
        .where("parentId", isEqualTo: parentId) // Filter by parentId
        .limit(1) // Optimize query to check only one document
        .get();

    return querySnapshot.docs.isEmpty; // Returns true if at least one document exists
  }
}
