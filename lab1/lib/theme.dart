import 'package:flutter/material.dart';

// The only raw colour in the app: ColorScheme.fromSeed needs a seed.
// Every other colour is a role of the resulting ColorScheme.
const int _seedValue = 0xFF00796B;

ThemeData buildTheme(Brightness brightness) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(_seedValue),
    brightness: brightness,
  ),
);
