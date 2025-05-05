import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import '../controllers/qr_code_controller.dart';

class QrCodeView extends GetView<QrCodeController> {
  const QrCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildQrCodeSection(),
              const SizedBox(height: 32),
              _buildInstructionText(),
              const SizedBox(height: 42),
              _buildDoneButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar with "Download QR" action
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton(
            onPressed: () {
              // Add your download QR logic here
            },
            child: Text(
              "Download QR",
              style: AppTextStyles.MetropolisMedium.copyWith(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Profile section with avatar, name, and ID
  Widget _buildProfileSection() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(
              'assets/images/icecream.png'), // Replace with your image
        ),
        const SizedBox(height: 12),
        Text(
          "Student Name",
          style: AppTextStyles.MetropolisMedium.copyWith(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        Text(
          "Student ID: 12345678",
          style: AppTextStyles.MetropolisRegular.copyWith(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // QR Code container
  Widget _buildQrCodeSection() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Image.asset(
        'assets/images/qr_code.png', // Replace with your QR code image
        fit: BoxFit.contain,
      ),
    );
  }

  // Instruction text below QR code
  Widget _buildInstructionText() {
    return Text(
      "Scan the QR code above",
      style: AppTextStyles.MetropolisMedium.copyWith(
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }

  // "Done" button
  Widget _buildDoneButton() {
    return CustomButton(
      text: 'DONE',
      onPressed: () {
        // Add your logic here
      },
      isLoading: RxBool(false),
    );
  }
}
