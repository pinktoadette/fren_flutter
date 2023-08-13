import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class LocalJsonLocalization {
  final Locale locale;

  LocalJsonLocalization(this.locale);

  static LocalJsonLocalization? of(BuildContext context) {
    return Localizations.of<LocalJsonLocalization>(
        context, LocalJsonLocalization);
  }

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    final String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static const LocalizationsDelegate<LocalJsonLocalization> delegate =
      _LocalizationsDelegate();
}

class _LocalizationsDelegate
    extends LocalizationsDelegate<LocalJsonLocalization> {
  const _LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<LocalJsonLocalization> load(Locale locale) async {
    final localizations = LocalJsonLocalization(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<LocalJsonLocalization> old) {
    return false;
  }
}
