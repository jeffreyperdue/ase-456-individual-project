import 'package:flutter/material.dart';
import 'package:pet_link/app/theme.dart';
import 'package:pet_link/features/pets/presentation/pages/home_page.dart';
import 'package:pet_link/features/pets/presentation/pages/edit_pet_page.dart';

/// Root of your app (MaterialApp, routes, theme).
class PetLinkApp extends StatelessWidget {
  const PetLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetLink',
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/edit': (_) => const EditPetPage(),
      },
    );
  }
}
