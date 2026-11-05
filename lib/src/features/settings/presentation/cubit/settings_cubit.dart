import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settings_repository.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  const SettingsState(this.themeMode, this.language);
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;
  SettingsCubit(this.repository)
    : super(SettingsState(_parseTheme(repository.theme), repository.language));

  static ThemeMode _parseTheme(String value) => switch (value) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  Future<void> setTheme(ThemeMode mode) async {
    await repository.saveTheme(mode.name);
    emit(SettingsState(mode, state.language));
  }

  Future<void> setLanguage(String code) async {
    await repository.saveLanguage(code);
    emit(SettingsState(state.themeMode, code));
  }
}
