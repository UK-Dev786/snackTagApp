import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';

import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfeild.dart'; // Ensure this is imported correctly
import 'package:snacktag/widgets/reuse_button.dart'; // Ensure this is imported correctly
import '../controllers/sign_in_controller.dart'; // Ensure your controller is correctly imported

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define controllers, like textControllers for text fields
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return PopScope(
      canPop: false, // Prevent the user from going back
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Equal left and right padding
            child: Column(
              children: [
                // Padding to push the content down by 100 from the top
                const SizedBox(height: 200),

                // Row for "LOGIN" and "NEW USER? SIGN UP NOW"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOGIN',
                      style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 18,
                          color: const Color(
                              0xFF434343)), // Custom text style for heading
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the sign-up screen
                        Get.toNamed(Routes.SIGN_UP);
                      },
                      child: Text(
                        'NEW USER? SIGNUP NOW',
                        style: AppTextStyles.MetropolisRegular.copyWith(
                            fontSize: 13, color: const Color(0xFF858585)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15), // Space between Row and TextFields

                // Email TextField widget
                TextFieldWidget(
                  text: 'Email',
                  path: 'assets/icon/email.png',
                  keyboardType: TextInputType.emailAddress,
                  textController: emailController,
                ),

                const SizedBox(
                    height: 10), // Space between email and password fields

                // Password TextField widget
                TextFieldWidget(
                  text: 'Password',
                  path: 'assets/icon/unlock.png',
                  keyboardType: TextInputType.text,
                  textController: passwordController,
                  isPassword: true,
                ),

                const SizedBox(
                    height:
                        20), // Space between password field and login button

                // Custom Button
                CustomButton(
                  text: 'LOGIN',
                  onPressed: () {
                    // Handle login action here
                  },
                  isLoading: false.obs, // RxBool for loading state
                 // gradientColors: const [Colors.orange, Colors.red],
                  height: 60.0,
                  borderRadius: 12.0,
                  fontSize: 18.0,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                ),

                const SizedBox(
                    height:
                        20), // Space between login button and forgot password

                // Forgot password text aligned to the left with increased size
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      // Handle forgot password action here
                      Get.toNamed(Routes.FORGET_PASSWORD);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.MetropolisRegular.copyWith(
                          fontSize: 15, color: const Color(0xFF707070)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
