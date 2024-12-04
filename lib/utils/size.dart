import 'package:flutter/material.dart';
import 'screen_utils.dart';
import 'dart:math' show min, max;

class Sizes {
  // Core spacing system
  static double get xsmall => ScreenUtils.getResponsivePadding(8.0);
  static double get small => ScreenUtils.getResponsivePadding(16.0);
  static double get medium => ScreenUtils.getResponsivePadding(24.0);
  static double get large => ScreenUtils.getResponsivePadding(32.0);
  static double get xlarge => ScreenUtils.getResponsivePadding(48.0);

  // Border Radius
  static double get radiusXSmall => 4.0;
  static double get radiusSmall => 8.0;
  static double get radiusMedium => 12.0;
  static double get radiusLarge => 16.0;
  static double get radiusXLarge => 24.0;
  static double get radiusCircular => 999.0;

  // Font Sizes
  static double get fontXSmall => ScreenUtils.getResponsiveFontSize(12.0);
  static double get fontSmall => ScreenUtils.getResponsiveFontSize(14.0);
  static double get fontMedium => ScreenUtils.getResponsiveFontSize(16.0);
  static double get fontLarge => ScreenUtils.getResponsiveFontSize(20.0);
  static double get fontXLarge => ScreenUtils.getResponsiveFontSize(24.0);
  static double get fontXXLarge => ScreenUtils.getResponsiveFontSize(32.0);

  // Icon Sizes
  static double get iconXSmall => 16.0;
  static double get iconSmall => 20.0;
  static double get iconMedium => 24.0;
  static double get iconLarge => 32.0;
  static double get iconXLarge => 40.0;

  // Component Heights
  static double get buttonHeight => ScreenUtils.getResponsiveHeight(6.0);
  static double get inputHeight => ScreenUtils.getResponsiveHeight(7.0);
  static double get listItemHeight => ScreenUtils.getResponsiveHeight(8.0);
  static double get cardMinHeight => ScreenUtils.getResponsiveHeight(15.0);
  static double get cardMaxHeight => ScreenUtils.getResponsiveHeight(30.0);

  // Component Widths
  static double get cardWidth => ScreenUtils.getResponsiveWidth(90.0);
  static double get dialogWidth => ScreenUtils.getResponsiveWidth(80.0);
  static double get maxContentWidth => ScreenUtils.getResponsiveWidth(95.0);
  static double get sideMenuWidth => ScreenUtils.getResponsiveWidth(70.0);

  // Image Dimensions
  static double get imageThumb => ScreenUtils.getResponsiveWidth(15.0);
  static double get imageSmall => ScreenUtils.getResponsiveWidth(30.0);
  static double get imageMedium => ScreenUtils.getResponsiveWidth(50.0);
  static double get imageLarge => ScreenUtils.getResponsiveWidth(70.0);

  // Component Specific
  static double get appBarHeight => kToolbarHeight;
  static double get bottomNavHeight => 64.0;
  static double get fabSize => 56.0;
  static double get snackBarHeight => 48.0;
  static double get dividerHeight => 1.0;
  static double get chipHeight => 32.0;

  // Screen Edge Padding
  static EdgeInsets get screenPadding =>
      EdgeInsets.all(ScreenUtils.getResponsivePadding(16.0));

  static EdgeInsets get screenPaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: ScreenUtils.getResponsivePadding(16.0));

  static EdgeInsets get screenPaddingVertical =>
      EdgeInsets.symmetric(vertical: ScreenUtils.getResponsivePadding(16.0));

  // List Spacing
  static double get listSpacing => ScreenUtils.getResponsivePadding(12.0);
  static double get gridSpacing => ScreenUtils.getResponsivePadding(16.0);

  // Container Padding
  static EdgeInsets get containerPadding =>
      EdgeInsets.all(ScreenUtils.getResponsivePadding(16.0));

  // Card Padding
  static EdgeInsets get cardPadding =>
      EdgeInsets.all(ScreenUtils.getResponsivePadding(20.0));

  // Dialog Padding
  static EdgeInsets get dialogPadding =>
      EdgeInsets.all(ScreenUtils.getResponsivePadding(24.0));

  // Form Field Spacing
  static double get formFieldSpacing => ScreenUtils.getResponsivePadding(16.0);
  static double get inputPrefixSpacing =>
      ScreenUtils.getResponsivePadding(12.0);

  // Button Padding
  static EdgeInsets get buttonPadding => EdgeInsets.symmetric(
      horizontal: ScreenUtils.getResponsivePadding(24.0),
      vertical: ScreenUtils.getResponsivePadding(12.0));

  // Helper Methods
  static double getResponsiveWidth(double percentage) =>
      ScreenUtils.getResponsiveWidth(percentage);

  static double getResponsiveHeight(double percentage) =>
      ScreenUtils.getResponsiveHeight(percentage);

  static double getResponsiveFontSize(double baseSize) =>
      ScreenUtils.getResponsiveFontSize(baseSize);

  static double getScaledSize(double size) =>
      ScreenUtils.getResponsivePadding(size);

  // Orientation Specific
  static double getOrientationSpecificSize(double portrait, double landscape) {
    return ScreenUtils.isLandscape() ? landscape : portrait;
  }

  // Device Type Specific
  static double getDeviceSpecificSize(double mobile, double tablet) {
    return ScreenUtils.getDeviceSpecificWidth(mobile, tablet);
  }

  // Safe Area
  static EdgeInsets get safeAreaPadding => ScreenUtils.safeAreaPadding;

  // Screen Dimensions
  static double get screenWidth => ScreenUtils.screenWidth;
  static double get screenHeight => ScreenUtils.screenHeight;
  static double get statusBarHeight => ScreenUtils.statusBarHeight;
  static double get bottomBarHeight => ScreenUtils.bottomBarHeight;

  // Adaptive Sizes
  static double getAdaptiveSize(double value) =>
      ScreenUtils.getAdaptiveSize(value);

  // Screen Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 960.0;
  static const double breakpointDesktop = 1280.0;

  // Get size based on screen width
  static double getSizeByWidth(double size) {
    return (size / 375.0) * ScreenUtils.screenWidth;
  }

  // Get size based on screen height
  static double getSizeByHeight(double size) {
    return (size / 812.0) * ScreenUtils.screenHeight;
  }
}
