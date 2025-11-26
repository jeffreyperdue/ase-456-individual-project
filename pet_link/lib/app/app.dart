import 'package:flutter/material.dart';
import 'package:petfolio/app/theme.dart';
import 'package:petfolio/app/app_startup.dart';
import 'package:petfolio/app/main_scaffold.dart';
import 'package:petfolio/app/config.dart';
import 'package:petfolio/features/pets/presentation/pages/edit_pet_page.dart';
import 'package:petfolio/features/pets/presentation/pages/pet_detail_page.dart';
import 'package:petfolio/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:petfolio/features/auth/presentation/pages/login_page.dart';
import 'package:petfolio/features/auth/presentation/pages/signup_page.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/sharing/presentation/pages/share_pet_page.dart';
import 'package:petfolio/features/sharing/presentation/pages/sitter_dashboard_page.dart';
import 'package:petfolio/features/sharing/presentation/pages/public_pet_profile_page.dart';
import 'package:petfolio/features/onboarding/welcome_view.dart';
import 'package:petfolio/features/onboarding/success_view.dart';

/// Root of your app (MaterialApp, routes, theme).
class PetfolioApp extends StatelessWidget {
  const PetfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petfolio',
      theme: buildTheme(),
      initialRoute: RouteNames.root,
      routes: {
        RouteNames.root: (_) =>
            const AppStartup(child: AuthWrapper(child: MainScaffold())),
        RouteNames.login: (_) => const LoginPage(),
        RouteNames.signup: (_) => const SignUpPage(),
        RouteNames.welcome: (_) => const WelcomeView(),
        RouteNames.onboardingSuccess: (_) => const SuccessView(),
        RouteNames.sitterDashboard:
            (_) => const AuthWrapper(child: SitterDashboardPage()),
        // Use onGenerateRoute for passing arguments for edit
      },
      onGenerateRoute: (settings) {
        if (settings.name == RouteNames.editPet) {
          final args = settings.arguments; // may be null for create
          return MaterialPageRoute(
            builder:
                (_) => EditPetPage(
                  petToEdit:
                      args is Map && args['pet'] != null ? args['pet'] : null,
                ),
          );
        }
        if (settings.name == RouteNames.petDetail) {
          final args = settings.arguments;
          if (args is Map && args['pet'] is Pet) {
            return MaterialPageRoute(
              builder: (_) => PetDetailPage(pet: args['pet'] as Pet),
            );
          }
        }
        if (settings.name == RouteNames.sharePet) {
          final args = settings.arguments;
          if (args is Map && args['pet'] is Pet) {
            return MaterialPageRoute(
              builder: (_) => SharePetPage(pet: args['pet'] as Pet),
            );
          }
        }
        if (settings.name == RouteNames.publicProfile) {
          final args = settings.arguments;
          if (args is Map && args['tokenId'] is String) {
            return MaterialPageRoute(
              builder:
                  (_) =>
                      PublicPetProfilePage(tokenId: args['tokenId'] as String),
            );
          }
        }
        return null;
      },
    );
  }
}

