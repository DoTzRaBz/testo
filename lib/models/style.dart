import 'package:flutter/material.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';

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