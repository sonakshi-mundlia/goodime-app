import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '/providers/settings_provider.dart';
import '/providers/language_service.dart';
import 'package:provider/provider.dart';

String t(String key) => LanguageService.t(key);

class ExploreCategoriesScreen extends StatefulWidget {
  const ExploreCategoriesScreen({super.key});

  @override
  State<ExploreCategoriesScreen> createState() =>
      _ExploreCategoriesScreenState();
}

class _ExploreCategoriesScreenState
    extends State<ExploreCategoriesScreen> {
  String selectedCategory = "all";

  bool isLoading = false;
  List papers = [];

  final String baseUrl = "https://goodime-app.onrender.com";

  final List<String> categories = [
    "all",
    "agriculture",
    "agronomy",
    "artificial_intelligence",
    "astrophysics",
    "augmented_reality",
    "aerospace_engineering",
    "biology",
    "bioinformatics",
    "biotechnology",
    "biomedical_engineering",
    "big_data",
    "blockchain",
    "chemistry",
    "civil_engineering",
    "climate_science",
    "cloud_computing",
    "communication_systems",
    "computer_science",
    "computer_vision",
    "cybersecurity",
    "data_science",
    "deep_learning",
    "economics",
    "education",
    "electrical_engineering",
    "electronics_engineering",
    "environmental_science",
    "finance",
    "food_science",
    "genetics",
    "geology",
    "history",
    "human_computer_interaction",
    "inorganic_chemistry",
    "internet_of_things",
    "linguistics",
    "machine_learning",
    "materials_science",
    "mathematics",
    "mechanical_engineering",
    "medicine",
    "microbiology",
    "nanotechnology",
    "natural_language_processing",
    "neuroscience",
    "nuclear_physics",
    "oceanography",
    "organic_chemistry",
    "pharmacology",
    "philosophy",
    "physical_chemistry",
    "physics",
    "political_science",
    "psychology",
    "public_health",
    "quantum_computing",
    "quantum_physics",
    "renewable_energy",
    "robotics",
    "signal_processing",
    "social_science",
    "software_engineering",
    "space_science",
    "statistics",
    "virtual_reality",
  ];

  // ================= THEME (UNIFIED WITH OTHER SCREENS) =================
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get cardBg =>
      isDark ? Colors.grey.shade900 : Colors.white;

  Color get textColor =>
      isDark ? Colors.white : Colors.black;

  Color get linkColor =>
      isDark ? Colors.lightBlueAccent : Colors.blue.shade800;

  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
      blurRadius: 8,
      offset: const Offset(0, 3),
    )
  ];

  @override
  void initState() {
    super.initState();
    fetchPapers();
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Could not launch $url";
    }
  }



  // ================= FETCH =================
  Future<void> fetchPapers() async {
    setState(() => isLoading = true);

    try {
      String url;

      if (selectedCategory == "all") {
        url = "$baseUrl/trending";
      } else {
        url =
        "$baseUrl/categories/$selectedCategory";
      }

      final response =
      await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded =
        jsonDecode(response.body);

        setState(() {
          papers =
          List<Map<String, dynamic>>.from(
            decoded["data"] ?? [],
          );
        });
      } else {
        setState(() => papers = []);
      }
    } catch (e) {
      setState(() => papers = []);
    }

    setState(() => isLoading = false);
  }

  // ================= CHIP =================
  Widget chipSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((item) {
          final active = item == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: active,
              label: Text(item == "all" ? t("all") : t(item)),
              onSelected: (_) {
                setState(() => selectedCategory = item);
                fetchPapers();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= CARD (UNIFIED DESIGN) =================
  Widget paperCard(Map<String, dynamic> paper) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            paper["title"] ?? t("no_title"),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 6),

          // AUTHORS
          Text(
            paper["authors"] ?? t("unknown_authors"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 6),

          // YEAR + CITATIONS (compact)
          Text(
            "${t("year")}: ${paper["year"] ?? "N/A"}  •  ${t("citations")}: ${paper["citations"] ?? 0}",
            style: TextStyle(fontSize: 12, color: textColor),
          ),

          const SizedBox(height: 6),

          // VENUE
          Text(
            paper["venue"] ?? t("unknown"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          // SOURCE + LINK ROW (compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paper["source"] ?? "api",
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
              ),

              if (paper["url"] != null)
                InkWell(
                  onTap: () => openUrl(paper["url"]),
                  child: Text(
                    t("open_paper"),
                    style: TextStyle(
                      fontSize: 12,
                      color: linkColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(t("explore_categories")),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            chipSelector(),

            const SizedBox(height: 12),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : papers.isEmpty
                  ? Center(
                child: Text(t("no_papers_found")),
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount =
                  constraints.maxWidth < 700 ? 2 : 4;

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: papers.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth < 600
                          ? 1
                          : constraints.maxWidth < 1100
                          ? 3
                          : 3,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: constraints.maxWidth < 600 ? 1.4 : 2.0,
                    ),
                    itemBuilder: (context, index) {
                      return paperCard(papers[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),

      ),
    );
  }
}
