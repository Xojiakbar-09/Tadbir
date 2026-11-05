import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

/// All display strings are loaded from assets/lang/*.json at startup.
class AppText {
  AppText._();
  static final Map<String, Map<String, String>> _values = {};

  static Future<void> load() async {
    for (final code in ['uz', 'ru', 'en']) {
      final raw = await rootBundle.loadString('assets/lang/$code.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _values[code] = decoded.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }
  }

  static String of(BuildContext context, String key) {
    final language = context.watch<SettingsCubit>().state.language;
    return _lookup(language, key);
  }

  /// Use inside callbacks, dialogs and asynchronous handlers.
  /// Unlike [of], this does not subscribe to provider updates.
  static String read(BuildContext context, String key) {
    final language = context.read<SettingsCubit>().state.language;
    return _lookup(language, key);
  }

  static String _lookup(String language, String key) =>
      _values[language]?[key] ?? _values['uz']?[key] ?? key;
}
