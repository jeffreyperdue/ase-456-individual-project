import 'package:flutter/material.dart';
import 'package:petfolio/app/theme.dart';
import 'package:petfolio/features/pets/presentation/pages/home_page.dart';
import 'package:petfolio/features/pets/presentation/pages/edit_pet_page.dart';
import 'package:petfolio/features/pets/presentation/pages/pet_detail_page.dart';
import 'package:petfolio/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:petfolio/features/auth/presentation/pages/login_page.dart';
import 'package:petfolio/features/auth/presentation/pages/signup_page.dart';
import 'package:petfolio/features/pets/domain/pet.dart';

/// Root of your app (MaterialApp, routes, theme).
class PetfolioApp extends StatelessWidget {
  const PetfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petfolio',
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
