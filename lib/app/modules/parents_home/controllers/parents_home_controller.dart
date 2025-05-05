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
  var parentAddWalletModel = Rxn<ParentAddWalletModel>(); // Observable wallet model
  var isLoading = false.obs;
  final switchController = ValueNotifier<bool>(false);
  @override
  void onInit() {
    listenToWalletChanges(); // Start listening for real-time updates
    fetchChildren();

    super.onInit();
  }

  Future<void> deleteChildrenById(String parentId, String childId) async {
    print("Parent ID: $parentId, Child ID: $childId");

    final result = await parentHomeService.deleteChildByParentId(parentId, childId);
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
      parentHomeService.fetchChildrenByParentId(currentParent.uid).listen((children) {
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
          switchController.value = wallet.enableMonthlyReload; // Sync switch state
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
