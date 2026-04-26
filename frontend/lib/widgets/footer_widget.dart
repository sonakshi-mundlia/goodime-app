import 'package:flutter/material.dart';
import '/providers/settings_provider.dart';
import '/providers/language_service.dart';
import 'package:provider/provider.dart';

String t(String key) => LanguageService.t(key);

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final small = width < 360;
    final large = width >= 700;

    final titleSize = large
        ? 24.0
        : small
        ? 18.0
        : 20.0;

    final bodySize = large
        ? 15.0
        : small
        ? 12.0
        : 13.0;

    final smallTextSize = large
        ? 14.0
        : small
        ? 11.0
        : 12.0;

    final iconSize = large
        ? 24.0
        : small
        ? 16.0
        : 18.0;

    final spacing = large ? 20.0 : 14.0;

    // SAME GREY FOR BOTH THEMES
    final bgColor = const Color(0xFF2B2B2B);

    return Container(
      width: double.infinity,
      color: bgColor,

      //  no outer padding (full width block)
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BRAND
          Text(
            "Goodime AI",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          // DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t("footer.part1"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                height: 1.5,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ICON ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language,
                  size: iconSize, color: Colors.white),
              SizedBox(width: spacing),
              Icon(Icons.security,
                  size: iconSize, color: Colors.white),
              SizedBox(width: spacing),
              Icon(Icons.cloud,
                  size: iconSize, color: Colors.white),
              SizedBox(width: spacing),
              Icon(Icons.auto_awesome,
                  size: iconSize, color: Colors.white),
            ],
          ),

          const SizedBox(height: 16),

          // BOTTOM TEXT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t("footer.part2"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallTextSize,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
