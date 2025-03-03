import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive width factors
  static double getContentWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width > 1200) return 0.5; // Desktop
    if (width > 600) return 0.7; // Tablet
    return 0.9; // Mobile
  }

  // Dynamic padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width > 1200) return EdgeInsets.all(width * 0.1);
    if (width > 600) return EdgeInsets.all(width * 0.07);
    return EdgeInsets.all(width * 0.05);
  }

  // Responsive spacing
  static double getVerticalSpacing(BuildContext context) =>
      getScreenHeight(context) * 0.02;
  static double getImageHeight(BuildContext context) =>
      getScreenHeight(context) * 0.2;
}
