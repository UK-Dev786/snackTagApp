import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnack(String message) {
  Get.snackbar(
    'Error',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
    icon: const Icon(Icons.error, color: Colors.white),
    borderRadius: 8,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    isDismissible: true,
  );
}
