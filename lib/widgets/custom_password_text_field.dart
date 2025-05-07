import 'package:flutter/material.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class CustomPasswordFieldWidget extends StatefulWidget {
  final String hintText;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final bool? isVisible;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const CustomPasswordFieldWidget({
    super.key,
    required this.hintText,
    this.isReadOnly = false,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.controller,
    this.onChanged,
    this.validator,
    this.isVisible,
  });

  @override
  _CustomPasswordFieldWidgetState createState() =>
      _CustomPasswordFieldWidgetState();
}

class _CustomPasswordFieldWidgetState extends State<CustomPasswordFieldWidget> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isVisible == false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
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
              validator: widget.validator,
              controller: widget.controller,
              obscureText: _isObscure,
              style: AppTextStyles.MetropolisRegular.copyWith(
                color: const Color(0xFF4A4B4D),
                fontSize: 16,
              ),
              keyboardType: widget.keyboardType,
              readOnly: widget.isReadOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                labelText: widget.isReadOnly ? null : widget.hintText,
                hintText: widget.isReadOnly ? widget.hintText : null,
                hintStyle: AppTextStyles.MetropolisRegular.copyWith(
                  color: const Color(0xFFB6B7B7),
                  fontSize: 12,
                ),
                labelStyle: AppTextStyles.MetropolisRegular.copyWith(
                  color: const Color(0xFFB6B7B7),
                  fontSize: 12,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: widget.isVisible != null
                    ? IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
