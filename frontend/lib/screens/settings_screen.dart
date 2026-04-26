import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/settings_provider.dart';
import '/providers/language_service.dart';

String t(String key) => LanguageService.t(key);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> themes = ["Light", "Dark"];

  String? expandedItem;

  bool isOpen(String key) => expandedItem == key;

  void toggle(String key) {
    setState(() {
      expandedItem = isOpen(key) ? null : key;
    });
  }

  // ================= ITEM =================
  Widget settingItem({
    required String keyName,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final open = isOpen(keyName);

    return Column(
      children: [
        InkWell(
          onTap: () => toggle(keyName),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ICON CHANGE LOGIC
                Icon(
                  open
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
              ],
            ),
          ),
        ),

        // ================= EXPANDED CONTENT =================
        AnimatedCrossFade(
          firstChild: const SizedBox(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: child,
          ),
          crossFadeState: open
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  // ================= DIVIDER =================
  Widget divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 0.6,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
    );
  }

  String themeLabel(String value) {
    return value == "Light" ? t("light") : t("dark");
  }

  void showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t("ok")),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t("settings"),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          const SizedBox(height: 10),

          // ================= HEADER =================
          Column(
            children: [
              const CircleAvatar(
                radius: 28,
                child: Icon(Icons.settings),
              ),
              const SizedBox(height: 10),
              Text(
                t("settings"),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= LANGUAGE =================
          settingItem(
            keyName: "language",
            title: t("language_settings"),
            subtitle: settings.getLanguageName(settings.languageCode),
            child: Column(
              children: settings.languages.map((e) {
                final code = e["code"]!;
                return ListTile(
                  title: Text(settings.getLanguageName(code)),
                  onTap: () {
                    settings.setLanguage(code);
                  },
                );
              }).toList(),
            ),
          ),

          divider(context),

          // ================= THEME =================
          settingItem(
            keyName: "theme",
            title: t("theme_settings"),
            subtitle: themeLabel(settings.themeModeName),
            child: Column(
              children: themes.map((e) {
                return ListTile(
                  title: Text(themeLabel(e)),
                  onTap: () {
                    settings.setTheme(e);
                  },
                );
              }).toList(),
            ),
          ),

          divider(context),

          // ================= PRIVACY =================
          settingItem(
            keyName: "privacy",
            title: t("privacy"),
            subtitle: t("secure_data"),
            child: Column(
              children: [
                ListTile(
                  title: Text(t("secure_data")),
                  onTap: () {
                    showInfoDialog(
                      context,
                      t("secure_data"),
                      t("secure_data"),
                    );
                  },
                ),
                ListTile(
                  title: Text(t("biometric_login")),
                  onTap: () {
                    showInfoDialog(
                      context,
                      t("biometric_login"),
                      t("biometric_login"),
                    );
                  },
                ),
              ],
            ),
          ),

          divider(context),

          // ================= ABOUT =================
          settingItem(
            keyName: "about",
            title: t("about_app"),
            subtitle: "Version 1.0.0",
            child: ListTile(
              title: Text(t("app_description")),
              onTap: () {
                showInfoDialog(
                  context,
                  t("about_app"),
                  t("app_description"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}