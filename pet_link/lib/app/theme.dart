import 'package:flutter/material.dart';

ThemeData buildTheme() {
  // Simple, friendly default. You can tweak later.
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
    useMaterial3: true,
  );
}
