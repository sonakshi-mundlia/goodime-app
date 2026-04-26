import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'search_paper_screen.dart';
import 'explore_categories_screen.dart';
import 'trending_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '/providers/language_service.dart';
import '/providers/settings_provider.dart';
import '/providers/auth_provider.dart';
import '/widgets/home_card.dart';
import '/widgets/feature_widget.dart';
import '/widgets/footer_widget.dart';
import '/widgets/insight_widget.dart';

String t(String key) => LanguageService.t(key);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> uploadedFiles = [];
  http.Client? _client;
  bool _isCancelled = false;

  final String baseUrl = "https://goodime-backend.onrender.com";

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

  // ================= API =================
  Future<String> generateAISummary(String text) async {
    final auth = context.read<AuthProvider>();
    final lang = context.read<SettingsProvider>().languageCode;

    final response = await _client!.post(
      Uri.parse("$baseUrl/summary"),
      headers: {
        "Content-Type": "application/json",
        if (auth.token != null)
          "Authorization": "Bearer ${auth.token}",
      },
      body: jsonEncode({
        "text": text,
        "language": lang,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["summary"] ?? "No summary found";
    } else {
      throw Exception("Failed to generate summary");
    }
  }
  // ================= PICK FILE =================
  Future<void> pickFile() async {
    setState(() => isLoading = true);

    if (_isCancelled) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        setState(() => isLoading = false);
        return;
      }

      final file = result.files.single;

      // STEP 1: EXTRACT PDF TEXT (IMPORTANT)
      String extractedText = "";

      if (file.bytes != null) {
        extractedText = await extractPdfText(file.bytes!);
      }
      if (_isCancelled) return;

      // STEP 2: SEND TEXT TO AI
      final summary = await generateAISummary(extractedText);

      if (_isCancelled || !mounted) return;

      setState(() {
        uploadedFiles.insert(0, {
          "title": file.name,
          "summary": summary,
          "date": DateTime.now().toString().split(".")[0],
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("file_uploaded_success"))),
      );

    } catch (e) {
      print("PICK FILE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t("error")}: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void cancelUpload() {
    _isCancelled = true;
    _client?.close();
    _client = http.Client();
  }

  // ================= MENU =================
  Widget buildMenu(bool small, bool large) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    Color adaptive(Color c) {
      return isDark
          ? HSLColor.fromColor(c)
          .withLightness(0.72)
          .toColor()
          : HSLColor.fromColor(c)
          .withLightness(0.42)
          .toColor();
    }

    Widget menuItem(
        IconData icon,
        String title,
        Widget page,
        Color color,
        ) {
      final c = adaptive(color);

      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          cancelUpload();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(
            horizontal: large ? 16 : 14,
            vertical: large ? 14 : 12,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  large ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: c.withOpacity(.15),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: c,
                  size: large ? 24 : 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize:
                    large ? 16 : small ? 14 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(large ? 20 : 14),
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    t("app_name"),
                    style: TextStyle(
                      fontSize:
                      large ? 24 : 22,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t("app_description"),
                    style: TextStyle(
                      fontSize:
                      small ? 12 : 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.65),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).brightness ==
                    Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),          ],
        ),

        const SizedBox(height: 24),

        menuItem(
          Icons.search,
          t("search_paper"),
          const SearchPaperScreen(),
          Colors.blue,
        ),
        menuItem(
          Icons.category,
          t("explore_categories"),
          const ExploreCategoriesScreen(),
          Colors.purple,
        ),
        menuItem(
          Icons.trending_up,
          t("trending"),
          const TrendingScreen(),
          Colors.orange,
        ),
        menuItem(
          Icons.settings,
          t("settings"),
          const SettingsScreen(),
          Colors.green,
        ),
        menuItem(
          Icons.login,
          t("login"),
          const LoginScreen(),
          Colors.teal,
        ),
        menuItem(
          Icons.app_registration,
          t("register"),
          const RegisterScreen(),
          Colors.red,
        ),
      ],
    );
  }

  // ================= UPLOAD CARD =================
  Widget uploadCard(
      bool small,
      bool large,
      ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLoading ? null : pickFile,
      child: Container(
        padding: EdgeInsets.all(
          large ? 30 : small ? 18 : 24,
        ),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [
              Colors.blueGrey.shade400,
              Colors.blueGrey.shade100
            ]
                : [
              Colors.blue.shade400,
              Colors.blue.shade100
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload,
              size: large
                  ? 78
                  : small
                  ? 52
                  : 65,
              color: isDark
                  ? Colors.grey.shade700
                  : Colors.blue.shade700,
            ),
            const SizedBox(height: 14),
            Text(
              t("upload_file"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:
                large ? 24 : small ? 18 : 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t("tap_to_select_pdf"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:
                large ? 15 : 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(.65),
              ),
            ),
            if (isLoading)
              const Padding(
                padding:
                EdgeInsets.only(top: 14),
                child:
                CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  // ================= FEATURES =================
  Widget featuresCard(
      bool small,
      bool large,
      ) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: EdgeInsets.all(
        large ? 24 : 18,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(22),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(.45),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            t("features.heading"),
            style: TextStyle(
              fontSize:
              large ? 24 : 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          FeaturePoint(
            icon: Icons.auto_awesome,
            title: t("features.title1"),
            subtitle:
            t("features.subtitle1"),
          ),
          FeaturePoint(
            icon: Icons.psychology,
            title: t("features.title2"),
            subtitle:
            t("features.subtitle2"),
          ),
          FeaturePoint(
            icon: Icons.summarize,
            title: t("features.title3"),
            subtitle:
            t("features.subtitle3"),
          ),
          FeaturePoint(
            icon: Icons.lightbulb,
            title: t("features.title4"),
            subtitle:
            t("features.subtitle4"),
          ),
          FeaturePoint(
            icon: Icons.speed,
            title: t("features.title5"),
            subtitle:
            t("features.subtitle5"),
          ),
          FeaturePoint(
            icon: Icons.picture_as_pdf,
            title: t("features.title6"),
            subtitle:
            t("features.subtitle6"),
          ),
          FeaturePoint(
            icon: Icons.school,
            title: t("features.title7"),
            subtitle:
            t("features.subtitle7"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    final size = MediaQuery.of(context).size;

    final small = size.width < 360;
    final large = size.width >= 700;

    final padding =
    large ? 32.0 : small ? 12.0 : 20.0;

    return Scaffold(
      drawer: Drawer(
        backgroundColor:
        Theme.of(context).colorScheme.surface,
        child: buildMenu(small, large),
      ),

      appBar: AppBar(
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 0,
          ),
          children: [
            // ================= TOP IMAGE =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: ArtisticImageStack(
                images: [
                  'assets/images/circle.png',
                  'assets/images/star.png',
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= UPLOAD CARD =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: uploadCard(small, large),
            ),

            const SizedBox(height: 18),

            // ================= EMPTY STATE =================
            if (uploadedFiles.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    t("no_file_uploaded_yet"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 18),

            // ================= INSIGHT =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: const InsightSection(),
            ),

            const SizedBox(height: 18),

            // ================= FEATURES =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: featuresCard(small, large),
            ),

            const SizedBox(height: 20),

            // ================= FOOTER FULL WIDTH =================
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
