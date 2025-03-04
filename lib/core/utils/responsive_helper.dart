import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive width factors
  static double getContentWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // ปรับขนาดความกว้างของเนื้อหาตามขนาดหน้าจอ
    if (screenWidth > 1200) {
      return 0.4; // 40% of screen width for large screens
    } else if (screenWidth > 800) {
      return 0.6; // 60% of screen width for medium screens
    } else {
      return 0.9; // 90% of screen width for small screens
    }
  }

  // Dynamic padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.05;
    double verticalPadding =
        getVerticalSpacing(context) * 0.5; // ลดระยะห่างด้านบนลงครึ่งหนึ่ง

    // ปรับ padding ตามขนาดหน้าจอ
    if (screenWidth > 1200) {
      horizontalPadding = screenWidth * 0.2; // 20% padding for large screens
    } else if (screenWidth > 800) {
      horizontalPadding = screenWidth * 0.1; // 10% padding for medium screens
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  // Responsive spacing
  static double getVerticalSpacing(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // ปรับลดค่าเปอร์เซ็นต์ลงตามขนาดหน้าจอ
    if (screenHeight > 1200) {
      return screenHeight * 0.03; // 3% for large screens
    } else if (screenHeight > 800) {
      return screenHeight * 0.04; // 4% for medium screens
    } else {
      return screenHeight * 0.05; // 5% for small screens
    }
  }

  static double getImageHeight(BuildContext context) =>
      getScreenHeight(context) * 0.2;
}
