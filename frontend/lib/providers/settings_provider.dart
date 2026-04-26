import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _initialized = false;

  // Supported Languages
  final List<Map<String, String>> languages = [
    {"name": "English", "code": "en"},
    {"name": "中文", "code": "zh"},
    {"name": "Español", "code": "es"},
    {"name": "Français", "code": "fr"},
    {"name": "العربية", "code": "ar"},
    {"name": "Português", "code": "pt"},
    {"name": "Русский", "code": "ru"},
    {"name": "Deutsch", "code": "de"},
    {"name": "日本語", "code": "ja"},
    {"name": "한국어", "code": "ko"},
    {"name": "Italiano", "code": "it"},
    {"name": "Türkçe", "code": "tr"},
    {"name": "Nederlands", "code": "nl"},
    {"name": "Bahasa Indonesia", "code": "id"},
    {"name": "Tiếng Việt", "code": "vi"},
    {"name": "ไทย", "code": "th"},
    {"name": "हिन्दी", "code": "hi"},
    {"name": "বাংলা", "code": "bn"},
    {"name": "தமிழ்", "code": "ta"},
    {"name": "తెలుగు", "code": "te"},
    {"name": "मराठी", "code": "mr"},
    {"name": "ગુજરાતી", "code": "gu"},
    {"name": "ಕನ್ನಡ", "code": "kn"},
    {"name": "മലയാളം", "code": "ml"},
    {"name": "ਪੰਜਾਬੀ", "code": "pa"},
    {"name": "اردو", "code": "ur"},
    {"name": "ଓଡ଼ିଆ", "code": "or"},
    {"name": "فارسی", "code": "fa"},
    {"name": "עברית", "code": "he"},
  ];

  // Theme Options
  final List<String> themes = ["Light", "Dark"];

  // App UI Language
  String _languageCode = "en";

  // Search / AI Content Language
  String _contentLanguageCode = "en";

  // Theme
  String _themeMode = "Light";
  ThemeMode _themeModeEnum = ThemeMode.light;

  // =============================
  // GETTERS
  // =============================
  bool get initialized => _initialized;

  String get languageCode => _languageCode;

  String get contentLanguageCode => _contentLanguageCode;

  String get themeModeName => _themeMode;

  ThemeMode get themeMode => _themeModeEnum;

  // =============================
  //  INIT APP SETTINGS
  // =============================
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _languageCode = prefs.getString("language") ?? "en";
    _contentLanguageCode =
        prefs.getString("contentLanguage") ?? "en";

    _themeMode = prefs.getString("theme") ?? "Light";

    // Load App UI language JSON
    await LanguageService.load(_languageCode);

    _applyTheme(_themeMode);

    _initialized = true;
    notifyListeners();
  }

  // =============================
  // CHANGE APP UI LANGUAGE
  // Whole app text changes
  // =============================
  Future<void> setLanguage(String code) async {
    _languageCode = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", code);

    await LanguageService.load(code);

    notifyListeners();
  }

  // =============================
  //  CHANGE CONTENT LANGUAGE
  // Search / AI / Results only
  // =============================
  Future<void> setContentLanguage(String code) async {
    _contentLanguageCode = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("contentLanguage", code);

    notifyListeners();
  }

  // =============================
  // CHANGE THEME
  // =============================
  Future<void> setTheme(String theme) async {
    _themeMode = theme;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", theme);

    _applyTheme(theme);

    notifyListeners();
  }

  // =============================
  // APPLY THEME
  // =============================
  void _applyTheme(String theme) {
    if (theme == "Dark") {
      _themeModeEnum = ThemeMode.dark;
    } else {
      _themeModeEnum = ThemeMode.light;
    }
  }

  // =============================
  // GET LANGUAGE NAME
  // =============================
  String getLanguageName(String code) {
    return languages.firstWhere(
          (e) => e["code"] == code,
      orElse: () => {"name": "English"},
    )["name"]!;
  }
}
