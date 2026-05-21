import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '/providers/language_service.dart';
import 'package:provider/provider.dart';
import '/providers/settings_provider.dart';

String t(String key) => LanguageService.t(key);

class SearchPaperScreen extends StatefulWidget {
  const SearchPaperScreen({super.key});

  @override
  State<SearchPaperScreen> createState() => _SearchPaperScreenState();
}

class _SearchPaperScreenState extends State<SearchPaperScreen> {
  final keywordController = TextEditingController();

  String selectedCategory = "all";
  String selectedYear = "all";
  String selectedSort = "newest";
  int selectedLimit = 20;

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
    "big data",
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
  // ================= THEME HELPERS =================
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
  void dispose() {
    keywordController.dispose();
    super.dispose();
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

  // ================= SEARCH =================
  Future<void> searchPapers() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/search?keyword=${keywordController.text.trim()}"
              "&category=$selectedCategory"
              "&year=$selectedYear"
              "&sort=$selectedSort"
              "&limit=$selectedLimit",
        ),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          papers = List<Map<String, dynamic>>.from(decoded);
        });
      } else {
        setState(() => papers = []);
      }
    } catch (e) {
      setState(() => papers = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= DROPDOWN =================
  Widget _iconDropdown<T>({
    required IconData icon,
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) text,
    required Function(T?) onChanged,
  }) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(text(e)),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ================= FILTERS =================
  Widget _filtersRow() {
    return Row(
      children: [
        Expanded(
          child: _iconDropdown<String>(
            icon: Icons.category_outlined,
            label: t("category"),
            value: selectedCategory,
            items: categories,
            text: (e) => t(e),
            onChanged: (val) {
              setState(() => selectedCategory = val!);
              searchPapers();
            },
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: _iconDropdown<String>(
            icon: Icons.date_range_outlined,
            label: t("year"),
            value: selectedYear,
            items: const ["all", "2026", "2025", "2024"],
            text: (e) => t(e),
            onChanged: (val) {
              setState(() => selectedYear = val!);
              searchPapers();
            },
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: _iconDropdown<String>(
            icon: Icons.sort,
            label: t("sort"),
            value: selectedSort,
            items: const ["newest", "oldest", "citations"],
            text: (e) => t(e),
            onChanged: (val) {
              setState(() => selectedSort = val!);
              searchPapers();
            },
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: _iconDropdown<int>(
            icon: Icons.format_list_numbered,
            label: t("limit"),
            value: selectedLimit,
            items: const [10, 20, 50, 100],
            text: (e) => "$e",
            onChanged: (val) {
              setState(() => selectedLimit = val!);
              searchPapers();
            },
          ),
        ),
      ],
    );
  }

  // ================= CARD =================
  Widget _paperCard(dynamic paper) {
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

          // YEAR + CITATIONS (compact row)
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

          // LINK + SOURCE ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
        title: Text(t("search_papers")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: keywordController,
              onChanged: (_) => searchPapers(),
              decoration: InputDecoration(
                hintText: "Search papers...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _filtersRow(),

            const SizedBox(height: 20),

            if (isLoading)
              const CircularProgressIndicator(),

            if (!isLoading && papers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(t("no_papers_found")),
              ),

            if (!isLoading && papers.isNotEmpty)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth < 600
                        ? 2
                        : constraints.maxWidth < 1100
                        ? 3
                        : 3;

                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: papers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth < 600 ? 1 : 3,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: constraints.maxWidth < 600 ? 1.4 : 2.0,
                      ),
                      itemBuilder: (_, i) => _paperCard(papers[i]),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
