import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_text.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

enum PreferenceType { language, theme }

Future<void> showPreferenceSheet(BuildContext context, PreferenceType type) {
  final cubit = context.read<SettingsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: _PreferenceSheet(type: type),
    ),
  );
}

class _PreferenceSheet extends StatelessWidget {
  final PreferenceType type;
  const _PreferenceSheet({required this.type});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final language = type == PreferenceType.language;
    final values = language ? ['uz', 'ru', 'en'] : ['system', 'light', 'dark'];
    final selected = language ? settings.language : settings.themeMode.name;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        8,
        22,
        MediaQuery.viewPaddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.of(context, language ? 'language_title' : 'theme_title'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...values.map(
            (value) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppText.of(
                  context,
                  '${language ? 'language' : 'theme'}_$value',
                ),
              ),
              leading: Icon(
                language
                    ? Icons.translate_rounded
                    : value == 'dark'
                    ? Icons.dark_mode_outlined
                    : value == 'light'
                    ? Icons.light_mode_outlined
                    : Icons.settings_brightness_outlined,
              ),
              trailing: selected == value
                  ? const Icon(Icons.check_circle, color: Color(0xFF7656D6))
                  : null,
              onTap: () async {
                if (language) {
                  await context.read<SettingsCubit>().setLanguage(value);
                } else {
                  await context.read<SettingsCubit>().setTheme(
                    ThemeMode.values.byName(value),
                  );
                }
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
