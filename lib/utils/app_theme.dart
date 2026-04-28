import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────
/// App‑wide design tokens
/// ──────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Primary — Deep Emerald (nature / fresh food)
  static const primary = Color(0xFF2D6A4F);
  static const primaryLight = Color(0xFF52B788);
  static const primaryPale = Color(0xFFD8F3DC);

  // Accent — Warm Orange (appetite / energy)
  static const accent = Color(0xFFE76F51);
  static const accentLight = Color(0xFFF4A261);

  // Neutrals
  static const background = Color(0xFFFAF3E0);
  static const surface = Colors.white;
  static const text = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const border = Color(0xFFE8E8E8);
  static const divider = Color(0xFFF0F0F0);

  // Semantic
  static const favorite = Color(0xFFE74C3C);
  static const checked = Color(0xFF27AE60);
  static const error = Color(0xFFE74C3C);
}

class AppRadius {
  AppRadius._();
  static const double card = 16;
  static const double chip = 24;
  static const double button = 12;
  static const double input = 14;
  static const double image = 12;
  static const double sheet = 24;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration cardAccent = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration chip({bool selected = false}) => BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 1.2,
        ),
        boxShadow: selected ? AppShadows.soft : null,
      );

  static BoxDecoration input = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.input),
    boxShadow: AppShadows.soft,
  );

  static BoxDecoration imageFrame = BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.image),
    color: AppColors.background,
  );
}
