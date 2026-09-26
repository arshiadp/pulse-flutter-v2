import 'package:flutter/material.dart';

const mint = Color(0xFFA7F3CE);
const lavender = Color(0xFFC9BCF5);
const surface = Color(0xFF18232B);
const muted = Color(0xFFA5B5BD);
ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B131B),
  colorScheme: const ColorScheme.dark(
    primary: mint,
    onPrimary: Color(0xFF0B131B),
    secondary: lavender,
    onSecondary: Color(0xFF0B131B),
    secondaryContainer: Color(0xFF293B44),
    onSecondaryContainer: mint,
    tertiary: lavender,
    surface: surface,
    onSurface: Color(0xFFF5F6EE),
  ),
  fontFamily: 'PulseSans',
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF111D26),
    indicatorColor: mint,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? const Color(0xFF0B131B)
            : muted,
      ),
    ),
  ),
  navigationRailTheme: const NavigationRailThemeData(
    indicatorColor: mint,
    selectedIconTheme: IconThemeData(color: Color(0xFF0B131B)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 56),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontFamily: 'PulseSans',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: mint,
    thumbColor: mint,
    inactiveTrackColor: Color(0xFF354750),
  ),
);
