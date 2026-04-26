import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goodime_ai/main.dart';
import 'package:goodime_ai/providers/settings_provider.dart';
import 'package:goodime_ai/providers/auth_provider.dart';

void main() {
  testWidgets('basic app test', (WidgetTester tester) async {
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();

    final authProvider = AuthProvider();
    await authProvider.init();

    await tester.pumpWidget(
      MyApp(
        settingsProvider: settingsProvider,
        authProvider: authProvider,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
