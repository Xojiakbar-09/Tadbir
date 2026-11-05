import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class SettingsRepository {
  final Box<dynamic> box;
  SettingsRepository(this.box);

  String get theme => box.get('theme_mode', defaultValue: 'system') as String;
  String get language => box.get('language_code', defaultValue: 'uz') as String;
  Future<void> saveTheme(String value) => box.put('theme_mode', value);
  Future<void> saveLanguage(String value) => box.put('language_code', value);
}
