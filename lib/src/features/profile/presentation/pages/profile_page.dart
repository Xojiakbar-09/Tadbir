import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../data/profile_repository.dart';
import '../bloc/profile_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_option_tile.dart';
import '../widgets/preference_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        ProfileCubit(context.read<ProfileRepository>())..load(),
    child: const _ProfileView(),
  );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppText.read(context, 'logout')),
        content: Text(AppText.read(context, 'confirm_logout')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppText.read(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppText.read(context, 'logout')),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      await context.read<AuthRepository>().logout();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.signIn, (_) => false);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppText.read(context, 'retry'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsCubit>().state;
    return SafeArea(
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 115),
          children: [
            Text(
              AppText.of(context, 'profile'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              AppText.of(context, 'profile_subtitle'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            ProfileHeader(profile: state.profile, loading: state.loading),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.error),
              ),
              TextButton(
                onPressed: context.read<ProfileCubit>().load,
                child: Text(AppText.of(context, 'retry')),
              ),
            ],
            const SizedBox(height: 26),
            _GroupTitle(AppText.of(context, 'preferences')),
            const SizedBox(height: 10),
            Material(
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: .55),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ProfileOptionTile(
                    icon: Icons.language_rounded,
                    title: AppText.of(context, 'language'),
                    value: AppText.of(context, 'language_${settings.language}'),
                    onTap: () =>
                        showPreferenceSheet(context, PreferenceType.language),
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: scheme.outlineVariant,
                  ),
                  ProfileOptionTile(
                    icon: Icons.brightness_6_outlined,
                    title: AppText.of(context, 'theme'),
                    value: AppText.of(
                      context,
                      'theme_${settings.themeMode.name}',
                    ),
                    onTap: () =>
                        showPreferenceSheet(context, PreferenceType.theme),
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: scheme.outlineVariant,
                  ),
                  ProfileOptionTile(
                    icon: Icons.refresh_rounded,
                    title: AppText.of(context, 'refresh_profile'),
                    onTap: context.read<ProfileCubit>().load,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: Text(AppText.of(context, 'logout')),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: scheme.error.withValues(alpha: .25)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}
