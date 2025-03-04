import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Standard Material Design breakpoints
  static const double kMobileBreakpoint = 600; // Mobile breakpoint is < 600dp
  static const double kTabletBreakpoint = 1024; // Tablet is 600dp-1024dp
  static const double kDesktopBreakpoint = 1440; // Desktop is >= 1024dp

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Device type detection
  static bool isMobile(BuildContext context) =>
      getScreenWidth(context) < kMobileBreakpoint;
  static bool isTablet(BuildContext context) =>
      getScreenWidth(context) >= kMobileBreakpoint &&
      getScreenWidth(context) < kTabletBreakpoint;
  static bool isDesktop(BuildContext context) =>
      getScreenWidth(context) >= kTabletBreakpoint;

  // Responsive width factors according to Material Design
  static double getContentWidth(BuildContext context) {
    double screenWidth = getScreenWidth(context);

    if (screenWidth >= kTabletBreakpoint) {
      return 0.6; // 60% width for desktop (with max width constraint applied elsewhere)
    } else if (screenWidth >= kMobileBreakpoint) {
      return 0.75; // 75% width for tablets
    } else {
      return 0.92; // 92% width for mobile
    }
  }

  // Standard Material Design padding (using 8dp grid)
  static EdgeInsets getScreenPadding(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double horizontalPadding;
    double verticalPadding;

    if (screenWidth >= kTabletBreakpoint) {
      // Desktop
      horizontalPadding = 24.0;
      verticalPadding = 24.0;
    } else if (screenWidth >= kMobileBreakpoint) {
      // Tablet
      horizontalPadding = 24.0;
      verticalPadding = 16.0;
    } else {
      // Mobile
      horizontalPadding = 16.0;
      verticalPadding = 16.0;
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  // Standard Material Design element spacing
  static double getVerticalSpacing(BuildContext context) {
    double screenWidth = getScreenWidth(context);

    if (screenWidth >= kTabletBreakpoint) {
      return 24.0; // Standard spacing for desktop
    } else if (screenWidth >= kMobileBreakpoint) {
      return 16.0; // Standard spacing for tablet
    } else {
      return 16.0; // Standard spacing for mobile
    }
  }

  // Maximum content width following Material Design recommendations
  static double getMaxContentWidth(BuildContext context) {
    return 1200.0; // Standard maximum content width
  }

  static double getImageHeight(BuildContext context) =>
      getScreenHeight(context) * 0.2;

  // Standard padding values per Material Design
  static const EdgeInsets kDefaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets kSmallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets kLargePadding = EdgeInsets.all(24.0);
}
