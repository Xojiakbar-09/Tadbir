import 'package:flutter/material.dart';
import 'package:tadbir_go/src/features/main/presentation/main_screen.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_page.dart';

class AppRouter {
  AppRouter._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case splash:
        page = const SplashPage();
      case onboarding:
        page = const OnboardingScreen();
      case signIn:
        page = const SignInPage();
      case signUp:
        page = const SignUpPage();
      case home:
        page = const MainScreen();
      default:
        page = const Scaffold(body: Center(child: Text('Sahifa topilmadi')));
    }
    final authTransition = settings.name == signIn || settings.name == signUp;
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: authTransition ? 420 : 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: authTransition
                        ? const Offset(.04, .08)
                        : Offset.zero,
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          ),
    );
  }
}
