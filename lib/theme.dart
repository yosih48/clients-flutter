import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern, flat design system.
///
/// Cool neutral surfaces, one confident indigo accent, semantic money colours
/// (green = paid, amber = pending, red = danger). Cards are flat with hairline
/// borders instead of shadows; hierarchy comes from type size and weight.
/// Typeface: Heebo (Hebrew + Latin).
class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5); // indigo 600
  static const Color primaryDark = Color(0xFF4338CA); // indigo 700
  static const Color primarySoft = Color(0xFFEEF0FF);
  static const Color accent = Color(0xFFF59E0B); // amber 500
  static const Color accentSoft = Color(0xFFFEF3C7);

  // Light surfaces
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F1F4);
  static const Color outline = Color(0xFFE3E5EA);

  // Text
  static const Color ink = Color(0xFF111318);
  static const Color inkMuted = Color(0xFF5F6472);
  static const Color inkFaint = Color(0xFF9CA1AE);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEE2E2);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF0C0D10);
  static const Color darkSurface = Color(0xFF16181D);
  static const Color darkSurfaceMuted = Color(0xFF20232A);
  static const Color darkOutline = Color(0xFF2A2E36);
  static const Color darkPrimary = Color(0xFF8B8CFF);
  static const Color darkInk = Color(0xFFF2F3F5);
  static const Color darkInkMuted = Color(0xFFA3A8B5);
}

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 26;
  static const double pill = 999;
}

class AppShadows {
  /// Cards are flat; this is a barely-there lift for floating elements.
  static List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF111318).withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lifted = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.22),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTheme {
  static final ThemeData lightTheme = _build(brightness: Brightness.light);
  static final ThemeData darkTheme = _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;

    final Color primary = isDark ? AppColors.darkPrimary : AppColors.primary;
    final Color onPrimary = isDark ? const Color(0xFF0C0D10) : Colors.white;
    final Color bg = isDark ? AppColors.darkBackground : AppColors.background;
    final Color surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final Color surfaceMuted =
        isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final Color outline = isDark ? AppColors.darkOutline : AppColors.outline;
    final Color ink = isDark ? AppColors.darkInk : AppColors.ink;
    final Color inkMuted = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
    final Color primaryContainer =
        isDark ? const Color(0xFF26275A) : AppColors.primarySoft;
    final Color onPrimaryContainer =
        isDark ? const Color(0xFFD9DAFF) : const Color(0xFF2E2A9E);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: AppColors.accent,
      onSecondary: AppColors.ink,
      secondaryContainer: isDark ? const Color(0xFF3A2E10) : AppColors.accentSoft,
      onSecondaryContainer: isDark ? const Color(0xFFFDE68A) : const Color(0xFF7C4A03),
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: inkMuted,
      surfaceContainerLowest: bg,
      surfaceContainerLow: isDark ? const Color(0xFF121418) : const Color(0xFFF9FAFB),
      surfaceContainer: surfaceMuted,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest: surfaceMuted,
      outline: outline,
      outlineVariant: outline,
      inverseSurface: isDark ? AppColors.darkInk : AppColors.ink,
      onInverseSurface: isDark ? AppColors.ink : Colors.white,
      surfaceTint: Colors.transparent,
    );

    final TextTheme base = TextTheme(
      displayLarge: TextStyle(
          fontSize: 40, fontWeight: FontWeight.w800, height: 1.05, color: ink),
      displayMedium: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w800, height: 1.1, color: ink),
      headlineLarge:
          TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink),
      headlineMedium:
          TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink),
      headlineSmall:
          TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
      titleLarge:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
      titleMedium:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink),
      titleSmall:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, height: 1.45, color: ink),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, height: 1.45, color: ink),
      bodySmall:
          TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, color: inkMuted),
      labelLarge:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      labelMedium:
          TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: inkMuted),
      labelSmall:
          TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: inkMuted),
    );
    final TextTheme textTheme = GoogleFonts.heeboTextTheme(base);
    final String? fontFamily = textTheme.bodyMedium?.fontFamily;

    RoundedRectangleBorder rounded(double r) =>
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: outline,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      visualDensity: VisualDensity.standard,

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
        titleTextStyle: textTheme.titleLarge
            ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: primaryContainer,
        indicatorShape: rounded(AppRadius.md),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              size: 24,
              color: s.contains(WidgetState.selected)
                  ? onPrimaryContainer
                  : inkMuted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
            textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? ink : inkMuted,
            )),
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
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? surfaceMuted : primary),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? inkMuted : onPrimary),
          iconColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.disabled) ? inkMuted : onPrimary),
          overlayColor:
              WidgetStateProperty.all(onPrimary.withOpacity(0.08)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 22, vertical: 15)),
          shape: WidgetStateProperty.all(rounded(AppRadius.md)),
          textStyle: WidgetStateProperty.all(textTheme.labelLarge
              ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
          minimumSize: WidgetStateProperty.all(const Size(0, 52)),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          minimumSize: const Size(0, 52),
          shape: rounded(AppRadius.md),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: outline, width: 1.2),
          backgroundColor: surface,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          minimumSize: const Size(0, 52),
          shape: rounded(AppRadius.md),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: rounded(AppRadius.sm),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.transparent,
          shape: rounded(AppRadius.sm),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceMuted : surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: inkMuted, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: inkMuted, fontWeight: FontWeight.w500),
        floatingLabelStyle:
            TextStyle(color: primary, fontWeight: FontWeight.w600),
        prefixIconColor: inkMuted,
        suffixIconColor: inkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surface),
          elevation: WidgetStateProperty.all(3),
          shape: WidgetStateProperty.all(rounded(AppRadius.md)),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: rounded(AppRadius.md),
        textStyle: textTheme.bodyMedium,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : inkMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : surfaceMuted),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.transparent : outline),
      ),

      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: outline, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: rounded(AppRadius.lg),
        extendedTextStyle: textTheme.labelLarge
            ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: inkMuted,
        textColor: ink,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: rounded(AppRadius.md),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: rounded(AppRadius.xl),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(fontSize: 15),
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
        backgroundColor: isDark ? AppColors.darkInk : AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.ink : Colors.white,
            fontWeight: FontWeight.w500),
        shape: rounded(AppRadius.md),
        elevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: rounded(AppRadius.pill),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? (isDark ? primaryContainer : surface)
                  : surfaceMuted),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? ink : inkMuted),
          iconColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? primary : inkMuted),
          side: WidgetStateProperty.all(BorderSide(color: surfaceMuted, width: 3)),
          shape: WidgetStateProperty.all(rounded(AppRadius.md)),
          textStyle: WidgetStateProperty.all(
              textTheme.labelLarge?.copyWith(fontSize: 13.5)),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: surfaceMuted,
        linearTrackColor: surfaceMuted,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkInk : AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.ink : Colors.white),
      ),
    );
  }
}
