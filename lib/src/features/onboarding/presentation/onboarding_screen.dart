import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/presentation/cubit/settings_cubit.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../../../core/consts/app_themes.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/premium_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;
  bool finishing = false;
  final pages = const [
    _Slide(
      Icons.confirmation_number_rounded,
      'onboarding_title_1',
      'onboarding_description_1',
      AppThemes.purple,
    ),
    _Slide(
      Icons.calendar_month_rounded,
      'onboarding_title_2',
      'onboarding_description_2',
      Color(0xFF638AD7),
    ),
    _Slide(
      Icons.location_on_rounded,
      'onboarding_title_3',
      'onboarding_description_3',
      Color(0xFF9670E4),
    ),
  ];
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> finish() async {
    if (finishing) return;
    setState(() => finishing = true);
    try {
      await Hive.box('settings').put('onboarding_completed', true);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.signIn,
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.read(context, 'something_went_wrong'))),
      );
    }
  }

  void next() {
    if (index == pages.length - 1) {
      finish();
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tadbir-Go',
                    style: TextStyle(
                      color: AppThemes.purple,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        tooltip: AppText.of(context, 'language'),
                        icon: const Icon(Icons.language_rounded),
                        onSelected: (code) =>
                            context.read<SettingsCubit>().setLanguage(code),
                        itemBuilder: (menuContext) => [
                          for (final code in ['uz', 'ru', 'en'])
                            PopupMenuItem<String>(
                              value: code,
                              child: Text(
                                AppText.read(context, 'language_$code'),
                              ),
                            ),
                        ],
                      ),
                      PopupMenuButton<ThemeMode>(
                        tooltip: AppText.of(context, 'theme'),
                        icon: Icon(
                          dark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        onSelected: (mode) =>
                            context.read<SettingsCubit>().setTheme(mode),
                        itemBuilder: (menuContext) => [
                          PopupMenuItem(
                            value: ThemeMode.system,
                            child: Text(AppText.read(context, 'theme_system')),
                          ),
                          PopupMenuItem(
                            value: ThemeMode.light,
                            child: Text(AppText.read(context, 'theme_light')),
                          ),
                          PopupMenuItem(
                            value: ThemeMode.dark,
                            child: Text(AppText.read(context, 'theme_dark')),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: finishing ? null : finish,
                        child: Text(AppText.of(context, 'skip')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (context, i) => _OnboardingPage(data: pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == index ? 28 : 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: i == index
                        ? AppThemes.purple
                        : (dark ? Colors.white24 : const Color(0xFFE8DFFD)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PremiumButton(
                text: AppText.of(
                  context,
                  index == pages.length - 1 ? 'get_started' : 'next',
                ),
                loading: finishing,
                onPressed: next,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title, text;
  final Color color;
  const _Slide(this.icon, this.title, this.text, this.color);
}

class _OnboardingPage extends StatelessWidget {
  final _Slide data;
  const _OnboardingPage({required this.data});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FloatingArt(icon: data.icon, color: data.color),
      const SizedBox(height: 40),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text(
              AppText.of(context, data.title),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Text(
              AppText.of(context, data.text),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.65,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .65),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
