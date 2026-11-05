import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sozlamalar')),
    body: BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Ko‘rinish', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<ThemeMode>(
            groupValue: state.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                context.read<SettingsCubit>().setTheme(mode);
              }
            },
            child: const Column(
              children: [
                RadioListTile(
                  title: Text('Tizim bilan bir xil'),
                  value: ThemeMode.system,
                ),
                RadioListTile(
                  title: Text('Yorug‘ mavzu'),
                  value: ThemeMode.light,
                ),
                RadioListTile(
                  title: Text('Qorong‘i mavzu'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Text('Til', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: state.language,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'uz', child: Text('O‘zbekcha')),
              DropdownMenuItem(value: 'ru', child: Text('Русский')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setLanguage(value);
              }
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Til tanlovi saqlanadi. Barcha ekranlarning tarjimalari keyingi bosqichda ulanadi.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
