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

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get cardBg => isDark ? Colors.grey.shade900 : Colors.white;
  Color get textColor => isDark ? Colors.white : Colors.black;
  Color get subText => isDark ? Colors.white70 : Colors.black54;
  Color get linkColor =>
      isDark ? Colors.lightBlueAccent : Colors.blue.shade700;

  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
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

  Future<void> fetchTrending() async {
    setState(() => isLoading = true);

    try {
      final response =
      await http.get(Uri.parse("$baseUrl/trending"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          trendingPapers =
          List<Map<String, dynamic>>.from(decoded["data"] ?? []);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => isLoading = false);
  }

  List<Map<String, dynamic>> getFiltered() {
    if (selectedCategory == "all") return trendingPapers;

    return trendingPapers.where((item) {
      final title =
      (item["title"] ?? "").toString().toLowerCase();

      return title.contains(
        selectedCategory.replaceAll("_", " ").toLowerCase(),
      );
    }).toList();
  }

  // ================= CARD =================
  Widget buildCard(
      Map<String, dynamic> item,
      bool mobile,
      bool tablet,
      ) {

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow,
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // TITLE
          Text(
            item["title"] ??
                t("no_title"),

            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              fontSize:
              mobile ? 14 : 16,

              fontWeight:
              FontWeight.w700,

              height: 1.3,

              color: textColor,
            ),
          ),

          const SizedBox(height: 10),

          // AUTHORS
          Text(
            item["authors"] ??
                t("unknown_authors"),

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              fontSize:
              mobile ? 12 : 13,

              color: subText,
            ),
          ),

          const SizedBox(height: 10),

          // YEAR + CITATIONS
          Row(
            children: [

              Expanded(
                child: Text(
                  "${t("year")}: ${item["year"] ?? "N/A"}",

                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize:
                    mobile ? 12 : 13,

                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  "${t("citations")}: ${item["citations"] ?? 0}",

                  textAlign:
                  TextAlign.end,

                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize:
                    mobile ? 12 : 13,

                    color: textColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // VENUE
          Text(
            item["venue"] ??
                t("unknown"),

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              fontSize:
              mobile ? 12 : 13,

              color: subText,
            ),
          ),

          const Spacer(),

          // FOOTER
          Row(
            children: [

              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration:
                  BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,

                    borderRadius:
                    BorderRadius.circular(8),
                  ),

                  child: Text(
                    item["source"] ??
                        "api",

                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize:
                      mobile ? 10 : 11,

                      fontWeight:
                      FontWeight.w500,

                      color: textColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              if (item["url"] != null)
                InkWell(
                  onTap: () =>
                      openUrl(
                        item["url"],
                      ),

                  child: Text(
                    t("open_paper"),

                    style: TextStyle(
                      fontSize:
                      mobile ? 11 : 12,

                      fontWeight:
                      FontWeight.w600,

                      color: linkColor,

                      decoration:
                      TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CATEGORY =================
  Widget categoryBar(
      bool mobile) {
    return SizedBox(
      height:
      mobile ? 38.0 : 42.0,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        itemCount:
        categories.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final cat =
          categories[index];

          return ChoiceChip(
            label: Text(
              t(cat),
              style:
              TextStyle(
                fontSize:
                mobile
                    ? 11.0
                    : 13.0,
              ),
            ),
            selected:
            selectedCategory ==
                cat,
            onSelected: (_) {
              setState(() {
                selectedCategory =
                    cat;
              });
            },
          );
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(
      BuildContext context) {
    context.watch<
        SettingsProvider>();

    return LayoutBuilder(
      builder:
          (context, constraints) {
        final double width =
            constraints.maxWidth;

        final bool mobile =
            width < 600;

        final bool tablet =
            width >= 600 &&
                width < 1000;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t("trending"),
              style:
              TextStyle(
                fontSize:
                mobile
                    ? 18.0
                    : 22.0,
                fontWeight:
                FontWeight
                    .w700,
              ),
            ),
            centerTitle:
            true,
            actions: [
              IconButton(
                icon:
                const Icon(
                  Icons
                      .refresh,
                ),
                onPressed:
                fetchTrending,
              ),
            ],
          ),
          body: Padding(
            padding:
            EdgeInsets.all(
              mobile
                  ? 10.0
                  : 16.0,
            ),
            child: Column(
              children: [
                categoryBar(
                    mobile),

                SizedBox(
                  height:
                  mobile
                      ? 10.0
                      : 16.0,
                ),

              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : getFiltered().isEmpty
                    ? Center(
                  child: Text(
                    t("no_trending_found"),
                    style: TextStyle(
                      fontSize: mobile ? 14 : 16,
                    ),
                  ),
                )
                    : LayoutBuilder(
                  builder: (context, gridConstraints) {

                    int crossAxisCount;

                    if (gridConstraints.maxWidth < 600) {
                      crossAxisCount = 1;
                    } else if (gridConstraints.maxWidth < 1000) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 20,
                      ),

                      itemCount: getFiltered().length,

                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: crossAxisCount,

                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,

                        // RESPONSIVE HEIGHT
                        childAspectRatio:
                        gridConstraints.maxWidth < 600
                            ? 1.7
                            : gridConstraints.maxWidth < 1000
                            ? 1.5
                            : 1.8,
                      ),

                      itemBuilder: (context, index) {
                        return buildCard(
                          getFiltered()[index],
                          mobile,
                          tablet,
                        );
                      },
                    );
                  },
                ),
              ),
              ],
            ),
          ),
        );
          },
    );
  }
}
