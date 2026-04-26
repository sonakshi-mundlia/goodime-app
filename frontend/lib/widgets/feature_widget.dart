import 'package:flutter/material.dart';

class FeaturePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeaturePoint({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final large = width >= 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorScheme = Theme.of(context).colorScheme;

    // MAIN CONTAINER BACKGROUND (UPDATED)
    final cardBg = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF4F5F7);

    final iconBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    final iconColor = isDark
        ? Colors.greenAccent.shade200
        : Colors.green.shade700;

    final textColor = colorScheme.onSurface;

    final iconSize = large ? 22.0 : 16.0;
    final iconPadding = large ? 15.0 : 10.0;

    final titleSize = large ? 17.0 : 13.0;
    final subtitleSize = large ? 15.0 : 12.0;

    final spacing = large ? 14.0 : 10.0;

    final verticalMargin = large ? 12.0 : 8.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: verticalMargin),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),

        // subtle border for depth
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.04),
        ),

        // soft elevation
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),

          SizedBox(width: spacing),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: large ? 6 : 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    height: 1.5,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}