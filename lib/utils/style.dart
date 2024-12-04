import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'dart:ui';

// Core Colors
class TahuraColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  // Background Colors
  static Color background = const Color(0xFF000500);
  static Color cardBackground = const Color(0xFF243647);
  static Color chatBackground = const Color(0xFF47698A);
  
  // Chat Colors
  static Color userChat = const Color(0xFF1A80E5);
  static Color resChat = const Color(0xFF243647);
  
  // Text Colors
  static Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white70;
  static Color hintColor = const Color(0xFF47698A);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Overlay Colors
  static Color overlay = Colors.black.withOpacity(0.5);
  static Color modalBarrier = Colors.black.withOpacity(0.3);
}

// Text Styles
class TahuraTextStyles {
  // Messages
  static TextStyle messageText = GoogleFonts.poppins(
    color: TahuraColors.textPrimary,
    fontSize: Sizes.fontMedium,
    height: 1.5,
  );

  // Headers
  static TextStyle appBarTitle = GoogleFonts.poppins(
    color: TahuraColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: Sizes.fontLarge,
  );
  
  static TextStyle screenTitle = GoogleFonts.poppins(
    color: TahuraColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: Sizes.fontXLarge,
  );

  // Body Text
  static TextStyle bodyText = GoogleFonts.poppins(
    color: TahuraColors.textPrimary,
    fontSize: Sizes.fontMedium,
  );

  static TextStyle bodyTextSecondary = GoogleFonts.poppins(
    color: TahuraColors.textSecondary,
    fontSize: Sizes.fontMedium,
  );

  // Input Fields
  static TextStyle hintText = GoogleFonts.poppins(
    color: TahuraColors.hintColor,
    fontSize: Sizes.fontMedium,
  );

  // Dates & Time
  static TextStyle dateText = GoogleFonts.poppins(
    color: TahuraColors.textPrimary,
    fontSize: Sizes.fontSmall,
  );

  // Buttons
  static TextStyle buttonText = GoogleFonts.poppins(
    color: TahuraColors.textPrimary,
    fontSize: Sizes.fontMedium,
    fontWeight: FontWeight.w600,
  );

  // Links
  static TextStyle linkText = GoogleFonts.poppins(
    color: TahuraColors.primary,
    fontSize: Sizes.fontMedium,
    decoration: TextDecoration.underline,
  );

  // Error Text
  static TextStyle errorText = GoogleFonts.poppins(
    color: TahuraColors.error,
    fontSize: Sizes.fontSmall,
  );
}

// Button Styles
class TahuraButtons {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: TahuraColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      horizontal: Sizes.medium,
      vertical: ScreenUtils.getResponsivePadding(12),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
    ),
    minimumSize: Size(
      ScreenUtils.getResponsiveWidth(80),
      ScreenUtils.getResponsiveHeight(6),
    ),
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: TahuraColors.primary,
    padding: EdgeInsets.symmetric(
      horizontal: Sizes.medium,
      vertical: ScreenUtils.getResponsivePadding(12),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      side: BorderSide(color: TahuraColors.primary),
    ),
    minimumSize: Size(
      ScreenUtils.getResponsiveWidth(80),
      ScreenUtils.getResponsiveHeight(6),
    ),
  );

  static ButtonStyle iconButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: TahuraColors.primary,
    shape: const CircleBorder(),
    padding: EdgeInsets.all(Sizes.small),
  );
}

// Input Decorations
class TahuraInputDecorations {
  static InputDecorationTheme get defaultInputTheme => InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      borderSide: BorderSide(color: TahuraColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      borderSide: BorderSide(color: TahuraColors.error),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: Sizes.medium,
      vertical: Sizes.small,
    ),
    hintStyle: TahuraTextStyles.hintText,
    errorStyle: TahuraTextStyles.errorText,
  );

  // Jika masih butuh InputDecoration, bisa tetap gunakan:
  static InputDecoration get defaultInput => InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      borderSide: BorderSide.none,
    ),
    // ... (sisanya sama seperti sebelumnya)
  );
}

// Card Decorations
class TahuraCards {
  static BoxDecoration defaultCard = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(Sizes.radiusLarge),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
    ),
  );

  static BoxDecoration elevatedCard = BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(Sizes.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration imageCard = BoxDecoration(
    borderRadius: BorderRadius.circular(Sizes.radiusLarge),
    image: DecorationImage(
      image: AssetImage('lib/assets/screen.png'),
      fit: BoxFit.cover,
    ),
  );
}

// Animation Durations
class TahuraAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// Gradients
class TahuraGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      TahuraColors.primary,
      TahuraColors.primaryDark,
    ],
  );

  static LinearGradient overlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black.withOpacity(0.7),
      Colors.black.withOpacity(0.3),
    ],
  );
}

// Shadows
class TahuraShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}