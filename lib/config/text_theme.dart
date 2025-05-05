import 'package:flutter/material.dart';

class TextThemes {
  /// Main text theme (default Flutter TextTheme)
  static TextTheme get textTheme {
    return ThemeData.light().textTheme;
  }

  /// Dark text theme (default Flutter TextTheme)
  static TextTheme get darkTextTheme {
    return ThemeData.dark().textTheme;
  }

  /// Light text theme (default Flutter TextTheme)
  static TextTheme get lightTextTheme {
    return ThemeData.light().textTheme;
  }
}
