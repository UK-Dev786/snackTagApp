import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:snacktag/app/routes/app_routes.dart';t';

import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/services/parents/parenents_services.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';

class ParentsProfileController extends GetxController {
  TextEditingController parentNameController = TextEditingController();

  RxString imageUrl = ''.obs;
  RxBool isLoading = false.obs;

  Rx<File?> selectedImage = Rx<File?>(null);

  // Future<void> validateAndContinue() async {
  //
  //   if(validate()){
  //
  //     isLoading.value = true;
  //
  //     var parentN = parentNameController.text;
  //
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //     String? userId = auth.currentUser?.uid;
  //
  //     if (selectedImage.value != null && userId != null) {
  //
  //
  //       imageUrl.value = await uploadImage(selectedImage.value!, "parents_details", userId);
  //
  //       print('Uploaded Image Url  🔴🔴🔴🔴🔴🔴${imageUrl.value}');
  //
  //       ParentsServices().addParentsInfo(parentN, imageUrl.value).then((val){
  //         // Get.offAllNamed(Routes.LANDING_PAGE);
  //       });
  //
  //     }
  //
  //   }
  //
  // }
  Future<void> validateAndContinue() async {
    if (validate()) {
      isLoading.value = true;

      var parentN = parentNameController.text;

      final FirebaseAuth auth = FirebaseAuth.instance;
      String? userId = auth.currentUser?.uid;

      if (selectedImage.value == null) {
        print("⚠️ No image selected.");
        isLoading.value = false;
        return;
      }
      print('✅ Uploaded Image URL: ${imageUrl.value}');

      if (userId != null) {
        try {
          imageUrl.value = await uploadImage(selectedImage.value!, "parents_details", userId);

          print('✅ Uploaded Image URL: ${imageUrl.value}');

          await ParentsServices().addParentsInfo(parentN, imageUrl.value).then((val) async {
            final FirebaseAuth auth = FirebaseAuth.instance;

            final user = auth.currentUser;
            print(" user value is  LLLLLllll ${user?.uid}");
            bool isWalletExist = await doesParentWalletExist(user!.uid);

            if (isWalletExist == true) {
              return Get.offNamed(Routes.PARENTS_ADD_WALLET);
            }
            // else if (isChildExist == true) {
            //   return Get.offNamed(Routes.PARENTS_CHILDREN_DETAILS);
            // }
            return Get.offNamed(Routes.LANDING_PAGE);
          });
          isLoading.value = false;

          // Navigate to the next page
          // Get.offAllNamed(Routes.LANDING_PAGE);
        } catch (e) {
          print("❌ Error: $e");
          isLoading.value = false;
          showCustomSnack("Image upload failed.");
        }
      } else {
        print("⚠️ User ID is null");
        isLoading.value = false;
        showCustomSnack("User authentication failed.");
      }
    }
  }

  Future<String> uploadImage(File imageFile, String folderName, String docId) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('$folderName/$docId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error Uploading Image 🔴🔴🔴🔴🔴🔴$e');
      throw Exception("Image upload failed: $e");
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('PickedFile Path${pickedFile.path}');
      selectedImage.value = File(pickedFile.path);
    }
  }

  bool validate() {
    var parentName = parentNameController.text;

    if (selectedImage.value == null) {
      showCustomSnack('Parents photo is required.');

      return false;
    }
    if (parentName.isEmpty) {
      showCustomSnack('Name fields are required.');

      return false;
    }

    return true;
  }

  // FOR CHECK THE PARENTS HAVE WALLET OR NOT
  Future<bool> doesParentWalletExist(String userId) async {
    QuerySnapshot<Map<String, dynamic>> walletSnapshot = await FirebaseFirestore.instance
        .collection(CollectionKey.USER_COLLECTION)
        .doc(userId) // Reference to the user document
        .collection("ParentWalletAmount") // Reference to the subcollection
        .limit(1) // Fetch at most one document (for efficiency)
        .get();
    // If there are documents in the subcollection, return true
    return walletSnapshot.docs.isEmpty;
  }


}
