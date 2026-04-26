import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'ai_summary_screen.dart';
import '/providers/language_service.dart';
import '/providers/settings_provider.dart';
import '/providers/auth_provider.dart';

import '/widgets/footer_widget.dart';
import '/widgets/dashboard_insight_widget.dart';

String t(String key) => LanguageService.t(key);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  bool isLoading = false;

  List<Map<String, dynamic>> uploadedFiles = [];

  final String baseUrl = "https://goodime-backend.onrender.com";
  http.Client? _client;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _client = http.Client();
  }

  @override
  void dispose() {
    _isCancelled = true;
    _client?.close();
    super.dispose();
  }


  Future<String> extractPdfText(List<int> bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);

    final text = extractor.extractText();

    document.dispose();

    return text;
  }

  // ================= AI SUMMARY =================
  Future<String> generateAISummary(String text, String language) async {
    try {
      final auth = context.read<AuthProvider>();

      final response = await _client!.post(
        Uri.parse("$baseUrl/summary"),
        headers: {
          "Content-Type": "application/json",
          if (auth.token != null)
            "Authorization": "Bearer ${auth.token}",
        },
        body: jsonEncode({
          "text": text,
          "language": language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["summary"] ?? "No summary found";
      } else {
        throw Exception("Failed to generate summary");
      }
    } catch (e) {
      rethrow;
    }
  }

  // ================= PICK FILE =================
  bool _isUploading = false;

  Future<void> pickFile() async {
    // HARD LOCK: prevent double execution
    if (_isUploading) {
      return;
    }

    _isUploading = true;

    setState(() {
      isLoading = true;
      _isCancelled = false;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (_isCancelled || result == null) {
        return;
      }

      final file = result.files.single;
      final lang = context.read<SettingsProvider>().languageCode;

      String extractedText = "";

      if (file.bytes != null) {
        extractedText = await extractPdfText(file.bytes!);
      }

      if (_isCancelled) return;

      if (extractedText.trim().isEmpty) {
        throw Exception("Could not extract text from PDF");
      }

      final summary = await generateAISummary(extractedText, lang);

      if (_isCancelled || !mounted) return;

      // NAVIGATION SAFETY CHECK
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AISummaryScreen(
            fileName: file.name,
            summary: summary,
          ),
        ),
      );

      setState(() {
        uploadedFiles.insert(0, {
          "title": file.name,
          "summary": summary,
          "date": DateTime.now().toString().split(".")[0],
        });
      });

    } catch (e) {
      print(" PICK FILE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t("error")}: $e")),
      );

    } finally {
      _isUploading = false;

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void handleTabChange(int i) {
    setState(() => currentIndex = i);

    if (i != 0) {
      _isCancelled = true;
      _client?.close();
      _client = http.Client();
    }
  }

  // ================= HERO SECTION =================
  Widget heroSection(BuildContext context, bool small, bool large) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;

    final textSize = small ? 14.0 : large ? 22.0 : 18.0;

    Widget textWidget = Expanded(
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: textSize,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            children: [
              TextSpan(text: "${t("main.part1")}\n\n"),
              TextSpan(
                text: "Gemini AI\n\n",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark
                      ? Colors.lightBlueAccent
                      : Colors.blue.shade900,
                ),
              ),
              TextSpan(text: t("main.part2")),
            ],
          ),
        ),
      ),
    );

    Widget imageWidget = Expanded(
      child: Center(
        child: SizedBox(
          height: large ? 320 : 240,
          child: Image.asset(
            "assets/images/search.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
    if (large) {
      return Row(
        children: [
          textWidget,
          imageWidget,
        ],
      );
    } else {
      return Column(
        children: [
          textWidget,
          const SizedBox(height: 10),
          imageWidget,
        ],
      );
    }
  }

  // ================= UPLOAD CARD =================
  Widget uploadCard(bool small, bool large) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: isLoading ? null : pickFile,
      child: Container(
        padding: EdgeInsets.all(large ? 28 : 20),

        decoration: BoxDecoration(
          color: Colors.transparent,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: borderColor.withOpacity(0.7),
            width: 1.2,
          ),
        ),

        child: Column(
          children: [
            Icon(
              Icons.upload_file,
              size: large ? 70 : 50,
              color: textColor,
            ),

            const SizedBox(height: 12),

            Text(
              t("upload_pdf"),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              t("tap_to_upload_ai"),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),

            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: CircularProgressIndicator(
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= HOME TAB =================
  Widget homeTab(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final small = size.width < 360;
    final large = size.width >= 700;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            children: [
              heroSection(context, small, large),
              const SizedBox(height: 28),

              uploadCard(small, large),
              const SizedBox(height: 18),

              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(t("no_file_uploaded_yet")),
                ),

              const SizedBox(height: 20),
              const DashboardInsightSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // FOOTER OUTSIDE PADDING BUT STILL SCROLLABLE
        const AppFooter(),
      ],
    );
  }
  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          homeTab(context),
          const HistoryScreen(),
          const ProfileScreen(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: handleTabChange,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: t("navigation.home"),
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: t("navigation.history"),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: t("navigation.profile"),
          ),
        ],
      ),
    );
  }
}
