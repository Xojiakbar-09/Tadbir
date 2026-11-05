import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:tadbir_go/src/features/auth/data/auth_repository.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/premium_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => start());
  }

  Future<void> start() async {
    final completed =
        Hive.box('settings').get('onboarding_completed', defaultValue: false) ==
        true;
    final isLoggedIn = completed
        ? await context.read<AuthRepository>().isLoggedIn()
        : false;
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      !completed
          ? AppRouter.onboarding
          : isLoggedIn
          ? AppRouter.home
          : AppRouter.signIn,
      (_) => false,
    );
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB39BFF), Color(0xFF7656D6), Color(0xFF4D2CB4)],
        ),
      ),
      child: Center(
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .76, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TgMark(size: 130),
                SizedBox(height: 24),
                Text(
                  'Tadbir-Go',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
