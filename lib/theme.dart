import 'package:flutter/material.dart';

/// Soft-modern design system.
///
/// Palette: warm cream surfaces, indigo primary, peach accent.
/// Generous rounding, very soft shadows, restrained type. Hebrew-friendly:
/// no enforced fontFamily so the platform default (with full Hebrew coverage)
/// is used everywhere.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF5B6CF5); // soft indigo
  static const Color primaryDark = Color(0xFF4453D9);
  static const Color primarySoft = Color(0xFFE9EBFF);
  static const Color accent = Color(0xFFFFB088); // peach
  static const Color accentSoft = Color(0xFFFFE9DC);

  // Light surfaces
  static const Color background = Color(0xFFF7F5F2); // warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1EEE9);
  static const Color outline = Color(0xFFE7E3DC);

  // Text
  static const Color ink = Color(0xFF1A1A2E);
  static const Color inkMuted = Color(0xFF6B6B7E);
  static const Color inkFaint = Color(0xFFA0A0B0);

  // Semantic
  static const Color success = Color(0xFF2EBD85);
  static const Color successSoft = Color(0xFFDFF6EC);
  static const Color warning = Color(0xFFF4A261);
  static const Color warningSoft = Color(0xFFFCEEDD);
  static const Color danger = Color(0xFFE5484D);
  static const Color dangerSoft = Color(0xFFFDE2E4);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF13141B);
  static const Color darkSurface = Color(0xFF1C1E27);
  static const Color darkSurfaceMuted = Color(0xFF252836);
  static const Color darkOutline = Color(0xFF2F3342);
  static const Color darkPrimary = Color(0xFF8B97FF);
  static const Color darkInk = Color(0xFFEFEEF6);
  static const Color darkInkMuted = Color(0xFFA5A8BD);
}

class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class AppShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.04),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> lifted = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppTheme {
  static final ThemeData lightTheme = _build(brightness: Brightness.light);
  static final ThemeData darkTheme = _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;

    final Color primary = isDark ? AppColors.darkPrimary : AppColors.primary;
    final Color bg = isDark ? AppColors.darkBackground : AppColors.background;
    final Color surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final Color surfaceMuted =
        isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final Color outline = isDark ? AppColors.darkOutline : AppColors.outline;
    final Color ink = isDark ? AppColors.darkInk : AppColors.ink;
    final Color inkMuted =
        isDark ? AppColors.darkInkMuted : AppColors.inkMuted;

    final ColorScheme scheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            onPrimary: Colors.white,
            secondary: AppColors.accent,
            onSecondary: AppColors.ink,
            surface: surface,
            onSurface: ink,
            error: AppColors.danger,
            onError: Colors.white,
            surfaceContainerHighest: surfaceMuted,
            outline: outline,
            outlineVariant: outline,
          )
        : ColorScheme.light(
            primary: primary,
            onPrimary: Colors.white,
            secondary: AppColors.accent,
            onSecondary: AppColors.ink,
            surface: surface,
            onSurface: ink,
            error: AppColors.danger,
            onError: Colors.white,
            surfaceContainerHighest: surfaceMuted,
            outline: outline,
            outlineVariant: outline,
          );

    final TextTheme textTheme = TextTheme(
      displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.05,
          color: ink),
      displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          height: 1.1,
          color: ink),
      headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: ink),
      headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: ink),
      headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: ink),
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: ink),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: ink),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, color: ink),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, color: ink),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: inkMuted),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: ink),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: inkMuted),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: inkMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: outline,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        iconTheme: IconThemeData(color: ink, size: 22),
        actionsIconTheme: IconThemeData(color: ink, size: 22),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: ink,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: outline, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.disabled)
                  ? surfaceMuted
                  : primary),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.08)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 22, vertical: 16)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md))),
          textStyle: WidgetStateProperty.all(const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1)),
          minimumSize: WidgetStateProperty.all(const Size(0, 52)),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: outline, width: 1.4),
          backgroundColor: surface,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: inkMuted, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: inkMuted, fontWeight: FontWeight.w500),
        floatingLabelStyle:
            TextStyle(color: primary, fontWeight: FontWeight.w600),
        prefixIconColor: inkMuted,
        suffixIconColor: inkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: outline, width: 1.2),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surface),
          elevation: WidgetStateProperty.all(2),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md))),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : surface),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : surfaceMuted),
        trackOutlineColor: WidgetStateProperty.all(outline),
      ),

      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: outline, width: 1.4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : inkMuted),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceMuted,
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.12),
        trackHeight: 6,
      ),

      dividerTheme:
          DividerThemeData(color: outline, thickness: 1, space: 1),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        extendedTextStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: inkMuted,
        textColor: ink,
        tileColor: Colors.transparent,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: ink),
        contentTextStyle: TextStyle(
            fontSize: 15, color: ink, height: 1.4),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primary,
        labelStyle:
            TextStyle(color: ink, fontWeight: FontWeight.w600, fontSize: 13),
        secondaryLabelStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
        width: 300,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) => s
                  .contains(WidgetState.selected)
              ? primary
              : surfaceMuted),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s
                  .contains(WidgetState.selected)
              ? Colors.white
              : ink),
          side: WidgetStateProperty.all(BorderSide.none),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill))),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: surfaceMuted,
      ),
    );
  }
}
