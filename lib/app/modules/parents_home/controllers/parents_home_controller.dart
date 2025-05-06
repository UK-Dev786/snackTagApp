import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';
import 'package:snacktag/services/parents/parent_home_service.dart';

class ParentsHomeController extends GetxController {
  final ParentHomeService parentHomeService = ParentHomeService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //TODO: Implement ParentsHomeController

  final count = 0.obs;
  // FETCHING CHILDREN DATA AGAINST PARENTS
  var childrenList = <ParentsAddChildren>[].obs;
  var parentAddWalletModel =
      Rxn<ParentAddWalletModel>(); // Observable wallet model
  var isLoading = false.obs;
  final switchController = ValueNotifier<bool>(false);

  // Add parent name observable
  var parentName = RxnString();

  // Add parent profile image observable
  var parentProfileImage = RxnString();

  @override
  void onInit() {
    listenToWalletChanges(); // Start listening for real-time updates
    fetchChildren();
    fetchParentInfo(); // Add this line to fetch parent info
    checkAndResetMonthlyExpenditures(); // Check if monthly expenditures need to be reset

    super.onInit();
  }

  // Add this method to fetch parent information
  void fetchParentInfo() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((doc) {
      if (doc.exists && doc.data() != null) {
        parentName.value = doc.data()!['parentsName'];
        parentProfileImage.value = doc.data()!['parentsPic'];
        print(
            "✅ Parent info loaded: ${parentName.value}, ${parentProfileImage.value}");
      }
    }).catchError((error) {
      print("❌ Error fetching parent info: $error");
    });
  }

  Future<void> deleteChildrenById(String parentId, String childId) async {
    print("Parent ID: $parentId, Child ID: $childId");

    final result =
        await parentHomeService.deleteChildByParentId(parentId, childId);
    if (result == true) {
      print("✅ Child deleted successfully. Refreshing list...");

      // Fetch updated list after deletion
      fetchChildren();
    } else {
      print("❌ Failed to delete child.");
    }
  }

  // FETCH CHILDREN DATA AGAINST PARENTS
  void fetchChildren() {
    isLoading.value = true;

    final currentParent = FirebaseAuth.instance.currentUser;
    if (currentParent != null) {
      parentHomeService.fetchChildrenByParentId(currentParent.uid).listen(
          (children) {
        childrenList.assignAll(children); // ✅ Automatically updates the UI
        print("✅ Children data updated: ${children.length} children found.");
      }, onError: (error) {
        print("❌ Error fetching children: $error");
      });
    }

    isLoading.value = false;
  }

  // Listen for real-time wallet data updates
  void listenToWalletChanges() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("❌ No logged-in user found.");
      return;
    }

    print("🚀 Listening for wallet updates for Parent ID: ${currentUser.uid}");

    parentHomeService.fetchWalletStreamByParentId(currentUser.uid).listen(
      (wallet) {
        parentAddWalletModel.value = wallet as ParentAddWalletModel;
        if (wallet != null) {
          switchController.value =
              wallet.enableMonthlyReload; // Sync switch state
        }
        print("🔄 Wallet data updated: ${wallet?.toJson()}");
      },
      onError: (error) {
        print("❌ Error fetching wallet data: $error");
      },
    );
  }

  // Toggle monthly reload switch in Firestore
  Future<void> toggleMonthlyReload(bool newValue) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || parentAddWalletModel.value == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('ParentWalletAmount')
          .doc(parentAddWalletModel.value!.id)
          .update({'enableMonthlyReload': newValue});

      print("✅ Monthly reload updated to: $newValue");
    } catch (e) {
      print("❌ Error updating monthly reload: $e");
    }
  }

  // Check and reset monthly expenditures if needed
  void checkAndResetMonthlyExpenditures() {
    final currentUser = _auth.currentUser;
    if (currentUser == null || parentAddWalletModel.value == null) return;

    // Get the current date
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final today = DateTime(now.year, now.month, now.day);

    // If today is the first day of the month, reset monthly expenditures
    if (today.isAtSameMomentAs(firstDayOfMonth)) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('ParentWalletAmount')
          .doc(parentAddWalletModel.value!.id)
          .update({'monthlyExpenditures': 0.0}).then((_) {
        print("✅ Monthly expenditures reset to 0");
      }).catchError((error) {
        print("❌ Error resetting monthly expenditures: $error");
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
