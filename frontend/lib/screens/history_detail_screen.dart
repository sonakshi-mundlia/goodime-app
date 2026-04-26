import 'package:flutter/material.dart';
import '/providers/language_service.dart';
import '/providers/settings_provider.dart';
import 'package:provider/provider.dart';

String t(String key) => LanguageService.t(key);

class HistoryDetailScreen extends StatelessWidget {
  final String fileName;
  final String summary;
  final String date;

  const HistoryDetailScreen({
    super.key,
    required this.fileName,
    required this.summary,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t("history_details")),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // File name
            Text(
              fileName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Date
            Text(
              date,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            // FULL SUMMARY
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}