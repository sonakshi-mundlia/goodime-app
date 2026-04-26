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
    final double titleSize =
    mobile ? 13.5 : tablet ? 15.0 : 16.0;

    final double textSize =
    mobile ? 11.5 : 12.5;

    final double smallSize =
    mobile ? 10.5 : 11.5;

    return Container(
      padding: EdgeInsets.all(
        mobile ? 10.0 : 14.0,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            item["title"] ?? t("no_title"),
            maxLines: mobile ? 2 : 3,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight:
              FontWeight.w700,
              color: textColor,
              height: 1.25,
            ),
          ),

          SizedBox(
            height:
            mobile ? 5.0 : 8.0,
          ),

          Text(
            item["authors"] ??
                t("unknown_authors"),
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: textSize,
              color: subText,
            ),
          ),

          SizedBox(
            height:
            mobile ? 5.0 : 8.0,
          ),

          Text(
            "${t("year")}: ${item["year"] ?? "N/A"}   •   ${t("citations")}: ${item["citations"] ?? 0}",
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: textSize,
              color: textColor,
            ),
          ),

          SizedBox(
            height:
            mobile ? 5.0 : 8.0,
          ),

          Text(
            item["venue"] ??
                t("unknown"),
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: textSize,
              color: subText,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration:
                BoxDecoration(
                  color: isDark
                      ? Colors
                      .grey
                      .shade800
                      : Colors
                      .grey
                      .shade200,
                  borderRadius:
                  BorderRadius
                      .circular(
                      6),
                ),
                child: Text(
                  item["source"] ??
                      "api",
                  style:
                  TextStyle(
                    fontSize:
                    smallSize,
                    color:
                    textColor,
                  ),
                ),
              ),

              const Spacer(),

              if (item["url"] !=
                  null)
                InkWell(
                  onTap: () =>
                      openUrl(
                        item["url"],
                      ),
                  child: Text(
                    t("open_paper"),
                    style:
                    TextStyle(
                      fontSize:
                      smallSize,
                      color:
                      linkColor,
                      fontWeight:
                      FontWeight
                          .w600,
                      decoration:
                      TextDecoration
                          .underline,
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

        final int columns =
        mobile
            ? 2
            : tablet
            ? 3
            : 4;

        final double ratio =
        mobile
            ? 0.78
            : tablet
            ? 0.95
            : 1.12;

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
                  child:
                  isLoading
                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                      : getFiltered()
                      .isEmpty
                      ? Center(
                    child:
                    Text(
                      t("no_trending_found"),
                      style:
                      TextStyle(
                        fontSize: mobile
                            ? 14.0
                            : 16.0,
                      ),
                    ),
                  )
                      : GridView.builder(
                    padding:
                    const EdgeInsets.only(
                      bottom:
                      20,
                    ),
                    itemCount:
                    getFiltered()
                        .length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      columns,
                      crossAxisSpacing:
                      mobile
                          ? 10.0
                          : 16.0,
                      mainAxisSpacing:
                      mobile
                          ? 10.0
                          : 16.0,
                      childAspectRatio:
                      ratio,
                    ),
                    itemBuilder:
                        (context,
                        index) {
                      return buildCard(
                        getFiltered()[
                        index],
                        mobile,
                        tablet,
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