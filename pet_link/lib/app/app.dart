import 'package:flutter/material.dart';
import 'package:pet_link/app/theme.dart';
import 'package:pet_link/features/pets/presentation/pages/home_page.dart';
import 'package:pet_link/features/pets/presentation/pages/edit_pet_page.dart';
import 'package:pet_link/features/pets/presentation/pages/pet_detail_page.dart';
import 'package:pet_link/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:pet_link/features/auth/presentation/pages/login_page.dart';
import 'package:pet_link/features/auth/presentation/pages/signup_page.dart';
import 'package:pet_link/features/pets/domain/pet.dart';

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
        '/': (_) => const AuthWrapper(child: HomePage()),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        // Use onGenerateRoute for passing arguments for edit
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final args = settings.arguments; // may be null for create
          return MaterialPageRoute(
            builder:
                (_) => EditPetPage(
                  petToEdit:
                      args is Map && args['pet'] != null ? args['pet'] : null,
                ),
          );
        }
        if (settings.name == '/pet-detail') {
          final args = settings.arguments;
          if (args is Map && args['pet'] is Pet) {
            return MaterialPageRoute(
              builder: (_) => PetDetailPage(pet: args['pet'] as Pet),
            );
          }
        }
        return null;
      },
    );
  }
}
