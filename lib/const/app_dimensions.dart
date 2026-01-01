import 'package:flutter/material.dart';

class AppDimensions {
  static late double screenWidth;
  static late double screenHeight;

  // Initialize dimensions based on the screen size
  static void initialize(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
  }

  // Padding constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Margin constants
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // Width and Height constants
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 15.0;

  // Other custom dimensions...
}
