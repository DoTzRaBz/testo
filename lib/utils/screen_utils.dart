import 'package:flutter/material.dart';
import 'dart:math' show max, min, pow, sqrt;
import 'dart:ui' show window;

class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double devicePixelRatio;
  static late double textScaleFactor;
  static late bool isTablet;
  static late bool isPhone;
  static late Orientation orientation;
  static late double statusBarHeight;
  static late double bottomBarHeight;

  static const double defaultScreenWidth = 375.0; // iPhone X width
  static const double defaultScreenHeight = 812.0; // iPhone X height
  static const double designScreenWidth = 375.0; // Design width from Figma/XD
  static const double designScreenHeight = 812.0; // Design height from Figma/XD
  static const bool allowFontScaling = false;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;
    textScaleFactor = _mediaQueryData.textScaleFactor;
    statusBarHeight = _mediaQueryData.padding.top;
    bottomBarHeight = _mediaQueryData.padding.bottom;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    isTablet = _isTablet();
    isPhone = !isTablet;
  }

  static bool _isTablet() {
    final double devicePixelRatio = window.devicePixelRatio;
    final double width = window.physicalSize.width;
    final double height = window.physicalSize.height;
    final double diagonalInches =
        _calcDiagonalInches(width, height, devicePixelRatio);
    return diagonalInches >= 7.0;
  }

  static double _calcDiagonalInches(
      double width, double height, double devicePixelRatio) {
    final double widthInches = width / (devicePixelRatio * 160);
    final double heightInches = height / (devicePixelRatio * 160);
    return sqrt(pow(widthInches, 2) + pow(heightInches, 2));
  }

  // Get proportional height according to screen size
  static double getProportionateScreenHeight(double inputHeight) {
    return (inputHeight / designScreenHeight) * screenHeight;
  }

  // Get proportional width according to screen size
  static double getProportionateScreenWidth(double inputWidth) {
    return (inputWidth / designScreenWidth) * screenWidth;
  }

  // Get responsive width based on percentage
  static double getResponsiveWidth(double percentage) {
    return screenWidth * (percentage / 100);
  }

  // Get responsive height based on percentage
  static double getResponsiveHeight(double percentage) {
    return screenHeight * (percentage / 100);
  }

  // Get scaling factor for responsive fonts
  static double getScaleFactor() {
    final double scaleFactor = min(screenWidth, screenHeight) /
        min(defaultScreenWidth, defaultScreenHeight);
    return scaleFactor;
  }

  // Get responsive font size
  static double getResponsiveFontSize(double fontSize) {
    double scaleFactor = getScaleFactor();
    final double calculatedFontSize = fontSize * scaleFactor;

    if (allowFontScaling) {
      return calculatedFontSize;
    } else {
      return calculatedFontSize / textScaleFactor;
    }
  }

  // Get responsive padding
  static double getResponsivePadding(double padding) {
    if (isTablet) {
      return padding * 1.5;
    }
    return padding;
  }

  // Get responsive margin
  static double getResponsiveMargin(double margin) {
    if (isTablet) {
      return margin * 1.5;
    }
    return margin;
  }

  // Get adaptive value based on orientation
  static double getAdaptiveSize(double value) {
    if (orientation == Orientation.landscape) {
      return value * 0.8;
    }
    return value;
  }

  // Get device specific width
  static double getDeviceSpecificWidth(double phone, double tablet) {
    return isTablet ? tablet : phone;
  }

  // Get device specific height
  static double getDeviceSpecificHeight(double phone, double tablet) {
    return isTablet ? tablet : phone;
  }

  // Check if device is in landscape mode
  static bool isLandscape() {
    return orientation == Orientation.landscape;
  }

  // Check if device is in portrait mode
  static bool isPortrait() {
    return orientation == Orientation.portrait;
  }

  // Get safe area padding
  static EdgeInsets get safeAreaPadding {
    return _mediaQueryData.padding;
  }

  // Get screen aspect ratio
  static double get aspectRatio {
    return screenWidth / screenHeight;
  }

  // Get minimum dimension (width or height)
  static double get minDimension {
    return min(screenWidth, screenHeight);
  }

  // Get maximum dimension (width or height)
  static double get maxDimension {
    return max(screenWidth, screenHeight);
  }

  // Get diagonal screen size in logical pixels
  static double get diagonalSize {
    return sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
  }
}
