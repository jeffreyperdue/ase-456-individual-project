// lib/main.dart
//
// WHAT THIS FILE DOES (beginner summary):
// - This is the tiny "bootstrap" of your app.
// - It turns on app-wide state (via Provider) and then launches your real app widget (PetLinkApp).
// - All UI screens are defined elsewhere (e.g., lib/app/app.dart and your features/ folders).
//
// NOTE: If your package name in pubspec.yaml is not 'pet_link', update the package:pet_link/... imports below.

import 'package:flutter/material.dart'; // Flutter's core UI toolkit: widgets, themes, etc.
import 'package:provider/provider.dart'; // Provider package: simple way to share state across the app.

// Your root app widget (defines MaterialApp, routes, theme).
// File path: lib/app/app.dart
import 'package:pet_link/app/app.dart';

// Your pets state manager (holds the in-memory list and notifies widgets to rebuild).
// File path: lib/features/pets/presentation/state/pet_list_provider.dart
import 'package:pet_link/features/pets/presentation/state/pet_list_provider.dart';

void main() {
  // runApp() starts your Flutter app. It expects a Widget (your root Widget).
  // We wrap our root app with "providers" so that any screen can read shared state.
  runApp(
    // MultiProvider lets you register one or more providers in a single place.
    // Even if you only have one provider today, using MultiProvider makes it easy to add more later.
    MultiProvider(
      providers: [
        // ChangeNotifierProvider creates and exposes ONE instance of PetListProvider
        // to the entire widget tree. Any widget below it can:
        //   - read()     -> access the provider without rebuilding
        //   - watch()    -> access and rebuild when the provider changes
        // PetListProvider uses notifyListeners() to tell the UI "data changed, rebuild".
        ChangeNotifierProvider(create: (_) => PetListProvider()),
      ],

      // 'child' is your actual app UI. Because it's wrapped by providers above,
      // every screen inside PetLinkApp can access those providers.
      child: const PetLinkApp(),
      // 'const' is an optimization: it says this widget has no changing constructor args,
      // which allows Flutter to do small performance improvements.
    ),
  );
}
