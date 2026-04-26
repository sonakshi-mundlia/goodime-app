import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '/providers/settings_provider.dart';
import '/providers/language_service.dart';
import 'package:provider/provider.dart';

String t(String key) => LanguageService.t(key);

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  List<Map<String, dynamic>> trendingPapers = [];
  bool isLoading = true;

  String selectedCategory = "all";

  final String baseUrl = "https://goodime-backend.onrender.com";

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

  // ================= THEME HELPERS (SAME AS SEARCH SCREEN) =================
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
    fetchTrending();
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
  Future<void> fetchTrending() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/trending"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          trendingPapers =
          List<Map<String, dynamic>>.from(data ?? []);
        });
      } else {
        throw Exception("Failed to load trending");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  // ================= FILTER =================
  List<Map<String, dynamic>> getFiltered() {
    if (selectedCategory == "all") return trendingPapers;

    return trendingPapers.where((item) {
      return item["category"] == selectedCategory;
    }).toList();
  }

  // ================= CARD (UNIFIED STYLE) =================
  Widget buildCard(Map<String, dynamic> item) {
    final textTheme = Theme.of(context).textTheme;

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
            item["title"] ?? t("no_title"),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          const SizedBox(height: 6),

          // AUTHORS
          Text(
            item["authors"] ?? t("unknown_authors"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: textColor.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 6),

          // YEAR + CITATIONS (compact line)
          Text(
            "${t("year")}: ${item["year"] ?? "N/A"}  •  ${t("citations")}: ${item["citations"] ?? 0}",
            style: textTheme.bodySmall?.copyWith(
              color: textColor,
            ),
          ),

          const SizedBox(height: 6),

          // VENUE
          Text(
            item["venue"] ?? t("unknown"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: textColor.withOpacity(0.6),
            ),
          ),

          const Spacer(),

          // BOTTOM ROW (SOURCE + LINK)
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
                  item["source"] ?? "api",
                  style: textTheme.labelSmall?.copyWith(
                    color: textColor,
                  ),
                ),
              ),

              if (item["url"] != null)
                InkWell(
                  onTap: () => openUrl(item["url"]),
                  child: Text(
                    t("open_paper"),
                    style: textTheme.bodySmall?.copyWith(
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

  // ================= CATEGORY BAR =================
  Widget categoryBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final active = cat == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t(cat)),
              selected: active,
              onSelected: (_) {
                setState(() => selectedCategory = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t("trending")),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTrending,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            categoryBar(),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : getFiltered().isEmpty
                  ? Center(
                child: Text(t("no_trending_found")),
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount =
                  constraints.maxWidth < 700 ? 2 : 4;

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: getFiltered().length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth < 600
                          ? 2
                          : constraints.maxWidth < 1100
                          ? 3
                          : 3, // max 3 columns on large screens
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 2.0,
                    ),
                    itemBuilder: (context, index) {
                      return buildCard(getFiltered()[index]);
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
