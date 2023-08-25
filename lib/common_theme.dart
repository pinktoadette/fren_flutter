// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/default_card_border.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum Environment {
  development,
  staging,
  production,
}

class MainTheme {
  static ThemeData lightTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      primaryColor: APP_PRIMARY_COLOR,
      colorScheme: const ColorScheme.light().copyWith(
        primary: APP_PRIMARY_COLOR,
        secondary: APP_ACCENT_COLOR,
        tertiary: APP_TERTIARY,
        tertiaryContainer: APP_TERTIARY, // drop shadow
        background: APP_PRIMARY_BACKGROUND,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: APP_PRIMARY_COLOR,
        labelColor: APP_PRIMARY_COLOR,
        labelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black26),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black54),
      ),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: APP_PRIMARY_COLOR),
          floatingLabelStyle:
              GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_COLOR),
          hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white30),
          errorStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: APP_ACCENT_COLOR, width: 2.0),
          )),
      dialogTheme: const DialogTheme(
          titleTextStyle: TextStyle(color: APP_PRIMARY_COLOR),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentTextStyle: TextStyle(
              fontSize: 16, fontFamily: 'poppins', color: APP_PRIMARY_COLOR),
          backgroundColor: APP_PRIMARY_BACKGROUND),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: APP_PRIMARY_COLOR,
      ),
      cardTheme: CardTheme(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent,
          elevation: 4.0,
          shape: defaultCardBorder()),
      textButtonTheme: TextButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: APP_PRIMARY_BACKGROUND,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black12,
        thickness: 1.0,
        space: 8.0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        modalBackgroundColor: Colors.white,
        backgroundColor: Colors.white70,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        // set shape to make top corners rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: APP_ACCENT_COLOR,
        selectionColor: Colors.green,
        selectionHandleColor: APP_ACCENT_COLOR,
      ),
      textTheme: TextTheme(
        displayLarge:
            GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w700),
        displayMedium:
            GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w500, color: APP_ACCENT_COLOR),
        headlineLarge:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium:
            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        headlineSmall: GoogleFonts.poppins(
            color: APP_PRIMARY_COLOR,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.poppins(fontSize: 18),
        titleSmall: GoogleFonts.poppins(fontSize: 16),
        bodyLarge:
            GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_COLOR),
        bodySmall: GoogleFonts.poppins(fontSize: 14),
        labelLarge:
            GoogleFonts.poppins(fontSize: 16, wordSpacing: 0, letterSpacing: 0),
        labelMedium: GoogleFonts.poppins(
            fontSize: 14,
            wordSpacing: 0,
            letterSpacing: 0,
            textStyle: const TextStyle(color: APP_ACCENT_COLOR)),
        labelSmall: GoogleFonts.poppins(
            fontSize: 12, wordSpacing: 0, letterSpacing: 0, color: Colors.grey),
      ).apply(
        bodyColor: APP_PRIMARY_COLOR,
        displayColor: APP_PRIMARY_COLOR,
      ),
      popupMenuTheme: PopupMenuThemeData(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      appBarTheme: const AppBarTheme(
        color: APP_PRIMARY_BACKGROUND,
        elevation: 0, //Platform.isIOS ? 0 : 4.0,
        iconTheme: IconThemeData(color: Colors.black),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white, // Only honored in Android M and above
            statusBarIconBrightness:
                Brightness.dark, // Only honored in Android M and above
            statusBarBrightness: Brightness.light),
        titleTextStyle: TextStyle(color: APP_PRIMARY_COLOR, fontSize: 18),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkTheme() {
    final ThemeData darkTheme = ThemeData.dark();
    const APP_PRIMARY_DARK_COLOR = Color.fromARGB(255, 184, 183, 183);
    const APP_PRIMARY_DARK_BACKGROUND = Color.fromARGB(255, 16, 16, 16);

    return darkTheme.copyWith(
      primaryColor: APP_PRIMARY_DARK_COLOR,
      colorScheme: const ColorScheme.dark().copyWith(
          primary: APP_PRIMARY_DARK_COLOR,
          secondary: APP_ACCENT_COLOR,
          tertiary: APP_TERTIARY,
          tertiaryContainer: Colors.black,
          background: APP_PRIMARY_DARK_BACKGROUND,
          inversePrimary: APP_PRIMARY_DARK_BACKGROUND,
          inverseSurface: APP_PRIMARY_DARK_COLOR),
      scaffoldBackgroundColor: APP_PRIMARY_DARK_BACKGROUND,
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1.0,
        space: 8.0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: APP_PRIMARY_DARK_BACKGROUND,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: APP_PRIMARY_DARK_COLOR,
        labelColor: APP_PRIMARY_DARK_COLOR,
        labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: APP_PRIMARY_DARK_COLOR),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: APP_TERTIARY),
      ),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: APP_ACCENT_COLOR,
          selectionColor: Color.fromARGB(255, 26, 158, 107),
          selectionHandleColor: Color.fromARGB(255, 22, 136, 92)),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(17)),
        isDense: true,
        fillColor: APP_INPUT_COLOR,
        filled: true,
        labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: APP_PRIMARY_DARK_COLOR),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle:
            GoogleFonts.poppins(fontSize: 18, color: APP_PRIMARY_DARK_COLOR),
        hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: APP_INVERSE_PRIMARY_COLOR),
        errorStyle: const TextStyle(fontSize: 16),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: APP_PRIMARY_COLOR,
      ),
      dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentTextStyle: TextStyle(fontSize: 16, fontFamily: 'poppins'),
          backgroundColor: APP_PRIMARY_DARK_BACKGROUND),
      cardTheme: CardTheme(
          color: const Color.fromARGB(255, 26, 26, 26),
          shadowColor: Colors.black,
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          shape: defaultCardBorder()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: APP_PRIMARY_DARK_COLOR,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: APP_PRIMARY_DARK_COLOR,
            foregroundColor: APP_PRIMARY_DARK_BACKGROUND,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: APP_PRIMARY_DARK_COLOR,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        modalBackgroundColor:
            APP_PRIMARY_DARK_BACKGROUND, //Color.fromRGBO(31, 31, 31, 1),
        backgroundColor: Color.fromARGB(255, 29, 29, 29),
        clipBehavior: Clip.antiAlias,
        // set shape to make top corners rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: APP_PRIMARY_DARK_COLOR,
      ),
      textTheme: TextTheme(
        displayLarge:
            GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w700),
        displayMedium:
            GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w500, color: APP_ACCENT_COLOR),
        headlineLarge:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium:
            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        headlineSmall: GoogleFonts.poppins(
            color: APP_PRIMARY_DARK_COLOR,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        titleLarge:
            GoogleFonts.poppins(fontSize: 24, color: APP_PRIMARY_DARK_COLOR),
        titleMedium:
            GoogleFonts.poppins(fontSize: 18, color: APP_PRIMARY_DARK_COLOR),
        titleSmall:
            GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_DARK_COLOR),
        bodyLarge:
            GoogleFonts.poppins(fontSize: 18, color: APP_PRIMARY_DARK_COLOR),
        bodyMedium:
            GoogleFonts.poppins(fontSize: 16, color: APP_PRIMARY_DARK_COLOR),
        bodySmall:
            GoogleFonts.poppins(fontSize: 14, color: APP_PRIMARY_DARK_COLOR),
        labelLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: APP_PRIMARY_DARK_COLOR,
            wordSpacing: 0,
            letterSpacing: 0),
        labelMedium: GoogleFonts.poppins(
            fontSize: 14,
            wordSpacing: 0,
            letterSpacing: 0,
            textStyle: const TextStyle(color: APP_ACCENT_COLOR)),
        labelSmall:
            GoogleFonts.poppins(fontSize: 12, wordSpacing: 0, letterSpacing: 0),
      ),
      popupMenuTheme: PopupMenuThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      appBarTheme: const AppBarTheme(
        color: APP_PRIMARY_DARK_BACKGROUND,
        elevation: 0, //Platform.isIOS ? 0 : 4.0,
        iconTheme: IconThemeData(color: APP_PRIMARY_DARK_COLOR),
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor:
                APP_PRIMARY_DARK_BACKGROUND, // Only honored in Android M and above
            statusBarIconBrightness:
                Brightness.light, // Only honored in Android M and above
            statusBarBrightness: Brightness.dark),
        titleTextStyle:
            TextStyle(fontFamily: 'poppins', color: Colors.white, fontSize: 16),
      ),
    );
  }

  // Add any methods related to theme customization if needed
}
