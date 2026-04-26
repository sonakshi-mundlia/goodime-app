import 'package:flutter/material.dart';
import '/providers/settings_provider.dart';
import '/providers/language_service.dart';
import 'package:provider/provider.dart';

String t(String key) => LanguageService.t(key);

class InsightSection extends StatelessWidget {
  const InsightSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;

    final isSmall = width < 360;
    final isLarge = width >= 700;

    final horizontalPadding = isLarge
        ? 28.0
        : isSmall
        ? 12.0
        : 16.0;

    final verticalPadding = isLarge ? 28.0 : 20.0;

    final titleSize = isLarge
        ? 26.0
        : isSmall
        ? 18.0
        : 22.0;

    final subSize = isLarge
        ? 16.0
        : isSmall
        ? 12.0
        : 14.0;

    final textSize = isLarge
        ? 15.5
        : isSmall
        ? 12.0
        : 13.5;

    final spacing = isLarge ? 16.0 : 10.0;

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontSize: titleSize,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
      letterSpacing: 0.4,
    );

    final subStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: subSize,
      color: colorScheme.onSurface.withOpacity(0.7),
      height: 1.5,
    );

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: textSize,
      fontWeight: FontWeight.w700,
      color: colorScheme.primary,
    );

    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: textSize,
      color: colorScheme.onSurface.withOpacity(0.75),
      height: 1.6,
    );

    Widget stepItem(String number, String title, String description) {
      return Padding(
        padding: EdgeInsets.only(bottom: spacing + 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$number.", style: labelStyle),
            SizedBox(width: isSmall ? 6 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: valueStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: valueStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1E1E1E),
              const Color(0xFF121212),
            ]
                : [
              const Color(0xFFF7F8FA),
              const Color(0xFFEDEFF3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.grey.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                t("insights.heading"),
                style: titleStyle,
              ),

              SizedBox(height: isLarge ? 10 : 6),

              Text(
                t("insights.subheading"),
                style: subStyle,
              ),

              SizedBox(height: isLarge ? 24 : 18),

              // STEPS (MORE DETAILED)
              stepItem(
                "1",
                t("insights.part1"),
                t("insights.subpart1"),
              ),

              stepItem(
                "2",
                t("insights.part2"),
                t("insights.subpart2"),
              ),

              stepItem(
                "3",
                t("insights.part3"),
                t("insights.subpart3"),
              ),

              stepItem(
                "4",
                t("insights.part4"),
                t("insights.subpart4"),
              ),

              stepItem(
                "5",
                t("insights.part5"),
                t("insights.subpart5"),
              ),

              stepItem(
                "6",
                t("insights.part6"),
                t("insights.subpart6"),
              ),

              stepItem(
                "7",
                t("insights.part7"),
                t("insights.subpart7"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
