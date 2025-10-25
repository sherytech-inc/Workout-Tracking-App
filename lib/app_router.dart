import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/workout_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';

  static String get initialRoute => login;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const WorkoutScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

// Simple guard you can use in widgets to redirect based on auth:
void guardAuth(BuildContext context) {
  final auth = context.read<AuthProvider>();
  final isLoggedIn = auth.user != null;
  final modal = ModalRoute.of(context)?.settings.name;
  if (isLoggedIn && modal != AppRouter.home) {
    Navigator.pushReplacementNamed(context, AppRouter.home);
  } else if (!isLoggedIn && modal != AppRouter.login) {
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }
}
