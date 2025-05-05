import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class SearchTextFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController textController;
  final Function(String)? onChanged;
  final Function()? onSubmit;
  final Function()? onTap;
  final FocusNode? focusNode;
  final bool isReadOnly;
  final List<TextInputFormatter>? inputFormatters;
  final double height;

  const SearchTextFieldWidget({
    super.key,
    required this.hintText,
    required this.textController,
    this.onChanged,
    this.onSubmit,
    this.onTap,
    this.focusNode,
    this.isReadOnly = false,
    this.inputFormatters,
    this.height = 56,
  });

  @override
  State<SearchTextFieldWidget> createState() => _SearchTextFieldWidgetState();
}

class _SearchTextFieldWidgetState extends State<SearchTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: widget.textController,
          focusNode: widget.focusNode,
          readOnly: widget.isReadOnly,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onSubmitted: widget.onSubmit != null ? (_) => widget.onSubmit!() : null,
          textInputAction: TextInputAction.search,
          style: AppTextStyles.PoppinsRegular.copyWith(
            fontSize: 14,
            color: const Color(0xFF4A4B4D),
          ),
          decoration: InputDecoration(
            suffixIcon: widget.textController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                widget.textController.clear();
                widget.onChanged?.call('');
              },
            )
                : null,
            hintText: widget.hintText,
            hintStyle: AppTextStyles.MetropolisRegular.copyWith(
              color: const Color(0xFFB6B7B7),
              fontSize: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
