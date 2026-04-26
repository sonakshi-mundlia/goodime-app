import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageService {
  static Map<String, dynamic> _map = {};
  static String _currentCode = "en";

  /// LOAD LANGUAGE WITH SAFETY
  static Future<void> load(String code) async {
    try {
      _currentCode = code;

      final data = await rootBundle.loadString(
        'assets/lang/$code.json',
      );

      _map = json.decode(data);
    } catch (e) {
      //  fallback to English if anything fails
      final fallback = await rootBundle.loadString(
        'assets/lang/en.json',
      );

      _map = json.decode(fallback);
      _currentCode = "en";
    }
  }

  /// TRANSLATION FUNCTION (Supports Nested Keys)
  static String t(String key) {
    if (_map.isEmpty) return key;

    final keys = key.split('.');
    dynamic value = _map;

    for (final k in keys) {
      if (value is Map<String, dynamic> &&
          value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }

    return value.toString();
  }

  /// optional helper
  static String get currentLanguage => _currentCode;
}