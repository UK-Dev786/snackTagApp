import 'package:flutter/material.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class SimpleTextFieldWidget extends StatelessWidget {
  final String hintText;
  final String? imagePath;
  final TextInputType keyboardType;
  final TextEditingController? controller; // Optional controller

  const SimpleTextFieldWidget({
    super.key,
    required this.hintText,
     this.imagePath,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 30, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller, // Assign the controller if provided
              style: AppTextStyles.MetropolisRegular.copyWith(
                color: const Color(0xFF4A4B4D),
                fontSize: 16,
              ),
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: hintText,
                labelStyle: AppTextStyles.MetropolisRegular.copyWith(
                  color: const Color(0xFFB6B7B7),
                  fontSize: 12,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        imagePath == null?const SizedBox():  Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                imagePath!,
                width: 17,
                height: 17,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
