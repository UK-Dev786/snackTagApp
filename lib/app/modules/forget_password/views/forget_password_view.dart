import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';
import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/forget_password_controller.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the controller for the email text field
    final TextEditingController emailController = TextEditingController();

    return WillPopScope(
      onWillPop: () async => false, // Prevent the user from going back
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 60), // Padding to push content down

                const SizedBox(height: 140), // Space between logo and form

                // Heading text
                Text(
                  'FORGOT PASSWORD',
                  style: AppTextStyles.MetropolisMedium.copyWith(
                    fontSize: 18,
                    color: const Color(0xFF434343),
                  ),
                ),

                const SizedBox(
                    height: 20), // Space between heading and text field

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'PLEASE ENTER YOUR EMAIL TO CREATE A LINK TO CREATE A NEW PASSWORD VIA EMAIL',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.MetropolisRegular.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF858585),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20), // Space between heading and text field

                // Email TextField widget
                TextFieldWidget(
                  text: 'Email',
                  path: 'assets/icon/email.png',
                  keyboardType: TextInputType.emailAddress,
                  textController: emailController,
                ),

                const SizedBox(
                    height: 30), // Space between text field and button

                // Custom button to submit the email
                CustomButton(
                  text: 'SEND',
                  onPressed: () {
                    // Handle the email submission action here
                    Get.toNamed(Routes.EMAIL_VERIFICATION);
                  },
                  isLoading: false.obs, // RxBool for loading state
                 // gradientColors: const [Colors.orange, Colors.red],
                  height: 60.0,
                  borderRadius: 12.0,
                  fontSize: 18.0,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                ),

                const SizedBox(
                    height: 20), // Space between button and footer text
              ],
            ),
          ),
        ),
      ),
    );
  }


}
