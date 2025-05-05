import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snacktag/config/validation.dart';
import 'dart:io';

import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/cefeteria_admin_services/add_staff_service.dart';

class CafeteriaEditStaffController extends GetxController {
  final AddStaffService _addStaffService = AddStaffService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserPreferences userPreferences = UserPreferences();

  var isLoading = false.obs;
  var isImageLoading = false.obs;
  var imageUrl = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['staffModelL'] != null) {
      setStaffData(Get.arguments['staffModelL']); // Corrected
    }
  }

  // Fetch staff details and set the form fields
  void setStaffData(StaffModel staff) {
    print("object name ${staff.staffName}");
    nameController.text = staff.staffName ?? '';
    emailController.text = staff.staffEmail ?? '';
    phoneController.text = staff.staffPhone ?? '';
    passwordController.text = staff.staffPassword ?? '';
    imageUrl.value = staff.imageUrl ?? '';
  }

  // Function to update staff data
  Future<void> editStaffData(String staffId) async {
    isLoading(true);

    var userId = await userPreferences.getUserId();
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar("Validation Error", "All fields are required");

      return;
    }
    if (!(Validator.isValidEmail(emailController.text))) {
      Get.snackbar("Validation Error", "Please Enter Valid Email");
      return;
    }
    try {

      StaffModel newModel = StaffModel(
        staffPassword: passwordController.text,
        staffEmail: emailController.text,
        staffName: nameController.text,
        staffPhone: phoneController.text,
        userId: userId,
        imageUrl: imageUrl.value
      );
      await _addStaffService.editStaffData(userId!, staffId, newModel.toMap()).then((val){

isLoading(false);
      });
      // await _firestore.collection('staff').doc(staffId).update({
      //   'staffName': nameController.text,
      //   'email': emailController.text,
      //   'phone': phoneController.text,
      //   'password': passwordController.text,
      //   'imageUrl': imageUrl.value,
      // });
      Get.snackbar('Success', 'Staff Data updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Function to pick an image and upload it to Firebase Storage
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = 'staff/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        isImageLoading(true);
        UploadTask uploadTask = _storage.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrl.value = downloadUrl;
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image');
      } finally {
        isImageLoading(false);
      }
    }
  }
}
