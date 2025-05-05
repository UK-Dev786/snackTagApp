import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final void Function() onTap;
  Widget widget;
   CustomBackButton({super.key,required this.onTap,required this.widget});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
        height: 35,
        width: 35,
        margin: const EdgeInsets.only(top: 16), // Add some margin if needed
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
          color: Colors.white, // Background color for the container
        ),
        child: Center(
          child: widget
        ),
      ),
    );
  }
}
