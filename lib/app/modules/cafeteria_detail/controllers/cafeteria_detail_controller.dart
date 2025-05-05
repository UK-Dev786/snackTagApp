import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:snacktag/services/authentication_service.dart';
import 'package:snacktag/services/user_service.dart';

import '../../../../widgets/custom_snackbar.dart';

class CafeteriaDetailController extends GetxController {

  TextEditingController schoolNameController = TextEditingController();
  TextEditingController cafeNameController = TextEditingController();

  RxString imageUrl = ''.obs;
  RxBool isLoading = false.obs;

  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> validateAndContinue() async {

    if(validate()){

      isLoading.value = true;

      var schoolName = schoolNameController.text;
      var cafeName = cafeNameController.text;

      final FirebaseAuth _auth = FirebaseAuth.instance;
      String? userId = _auth.currentUser?.uid;

      if (selectedImage.value != null && userId != null) {


        imageUrl.value = await uploadImage(selectedImage.value!, "cafeteria_details", userId);

        print('Uploaded Image Url  🔴🔴🔴🔴🔴🔴${imageUrl.value}');

        UserService().addCafeteriaInfo(cafeName, imageUrl.value, schoolName);

      }

    }

  }

  Future<String> uploadImage(
      File imageFile, String folderName, String docId) async {
    try {
      final FirebaseStorage _storage = FirebaseStorage.instance;
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error Uploading Image 🔴🔴🔴🔴🔴🔴$e');
      throw Exception("Image upload failed: $e");
    }
  }

  bool validate() {

    var schoolName = schoolNameController.text;
    var cafeName = cafeNameController.text;

    if(selectedImage.value == null) {

      showCustomSnack('Cafeteria photo is required.');

      return false;
    }
    if(schoolName.isEmpty) {

      showCustomSnack('All fields are required.');

      return false;
    }

    if(cafeName.isEmpty) {

      showCustomSnack('All fields are required.');

      return false;
    }

    return true;

  }
}
