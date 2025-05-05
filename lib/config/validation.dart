import 'package:flutter/material.dart';

class Validator {
  // Regular expression for email validation
  static bool isValidEmail(String email) {
    // Email regex pattern
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }
}