import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class TextFieldWidget extends StatefulWidget {
  final String text;
  final String? path;
  final String? onChangepath;
  final TextEditingController textController;
  final bool isPassword;
  final Function()? onEditComplete;
  final FocusNode? focusNode;
  final Function(String)? onSubmit;
  final Function(String)? onChanged;
  final Widget? prefixIcon;
  final bool isReadOnly;
  final Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool? isObscure;
  final bool isSuffix;
  final bool isSuffixBG;
  final bool isBGChangeColor;
  final double height;
  final double? width;

  const TextFieldWidget({
    super.key,
    required this.text,
    this.path,
    this.onChangepath,
    this.isSuffix = false,
    this.isSuffixBG = false,
    this.isBGChangeColor = false,
    required this.textController,
    this.onSubmit,
    this.height = 56,
    this.onChanged,
    this.isPassword = false,
    this.onEditComplete,
    this.focusNode,
    this.keyboardType,
    this.prefixIcon,
    this.inputFormatters,
    this.isReadOnly = false,
    this.onTap,
    this.isObscure,
    this.width = double.infinity,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  void _unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocus(context),
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: const EdgeInsets.only(left: 30, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: widget.isBGChangeColor
              ? const Color(0xFFF8FAFC)
              : AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          style: widget.isSuffix
              ? AppTextStyles.PoppinsRegular.copyWith(
                  fontSize: 13, // Set desired font size

                  color: const Color(0xFF4A4B4D), // Text color
                )
              : widget.isSuffixBG
                  ? AppTextStyles.PoppinsRegular.copyWith(
                      color: const Color(0xFF858585),
                      fontSize: 13,
                    )
                  : AppTextStyles.MetropolisRegular.copyWith(
                      color: const Color(0xFF4A4B4D),
                      fontSize: 16,
                    ),
          readOnly: widget.isReadOnly,
          obscureText: widget.isPassword,
          controller: widget.textController,
          onEditingComplete: widget.onEditComplete,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          onFieldSubmitted: widget.onSubmit,
          obscuringCharacter: '*',
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            labelText: widget.text, // Set label text
            labelStyle: widget.isSuffix
                ? AppTextStyles.PoppinsRegular.copyWith(
                    fontSize: 13, // Set desired font size

                    color: const Color(0xFF858585), // Text color
                  )
                : widget.isSuffixBG
                    ? AppTextStyles.PoppinsRegular.copyWith(
                        color: const Color(0xFF858585),
                        fontSize: 13,
                      )
                    : AppTextStyles.MetropolisRegular.copyWith(
                        color: const Color(0xFFB6B7B7),
                        fontSize: 12,
                      ),
            // hintText: widget.text, // Set hint text
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,

            suffixIcon: widget.isSuffix
                ? null
                : widget.isSuffixBG
                    ? Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: Image.asset(
                              widget.path!,
                              fit: BoxFit.contain,
                              color: const Color(0xFF6A6A6A),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 17.0,
                            height: 17.0,
                            child: Image.asset(
                              widget.path!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
