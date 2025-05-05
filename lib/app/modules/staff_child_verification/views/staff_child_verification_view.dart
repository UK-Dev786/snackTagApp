import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/staff_child_verification_controller.dart';

class StaffChildVerificationView
    extends GetView<StaffChildVerificationController> {
  const StaffChildVerificationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StaffChildVerificationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StaffChildVerificationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
