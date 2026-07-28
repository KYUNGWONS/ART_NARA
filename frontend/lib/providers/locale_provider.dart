import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.ko;

  AppLanguage get currentLanguage => _currentLanguage;

  String tr(Map<AppLanguage, String> translations) {
    return translations[_currentLanguage] ?? translations[AppLanguage.ko]!;
  }

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }
}
