import 'package:flutter/material.dart';
import '/providers/language_service.dart';

String t(String key) => LanguageService.t(key);

class ArtisticImageStack extends StatelessWidget {
  final List<String> images;

  const ArtisticImageStack({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final small = width < 360;
    final large = width >= 700;

    // ================= LARGE SCREEN =================
    if (large) {
      return Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          // LEFT IMAGE
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 340,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 20,
                    left: 40,
                    child: _img(
                      images[0],
                      230,
                      1.75,
                    ),
                  ),
                  Positioned(
                    top: 55,
                    left: 170,
                    child: _img(
                      images[1],
                      230,
                      1.85,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 30),

          // RIGHT TEXT
          Expanded(
            flex: 1,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Center(
                child: RichText(
                  textAlign:
                  TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.6,
                      fontWeight:
                      FontWeight.w500,
                      color: Theme.of(
                          context)
                          .colorScheme
                          .onSurface,
                    ),
                    children: [
                      TextSpan(
                        text:
                        "${t("main.part1")}\n\n",
                      ),
                      TextSpan(
                        text:
                        "Gemini AI\n\n",
                        style: TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                          color: Theme.of(
                              context)
                              .brightness ==
                              Brightness
                                  .dark
                              ? Colors
                              .lightBlueAccent
                              : Colors.blue
                              .shade900,
                        ),
                      ),
                      TextSpan(
                        text: t(
                            "main.part2"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ================= SMALL / MOBILE =================
    return Column(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: _img(
                  images[0],
                  160,
                  1.6,
                ),
              ),
              Positioned(
                top: 30,
                left: 50,
                child: _img(
                  images[1],
                  160,
                  1.7,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize:
              small ? 14 : 18,
              height: 1.5,
              fontWeight:
              FontWeight.w500,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface,
            ),
            children: [
              TextSpan(
                text:
                t("main.part1"),
              ),
              TextSpan(
                text:
                " Gemini AI ",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: Theme.of(
                      context)
                      .brightness ==
                      Brightness
                          .dark
                      ? Colors
                      .lightBlueAccent
                      : Colors.blue
                      .shade900,
                ),
              ),
              TextSpan(
                text:
                t("main.part2"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _img(
      String path,
      double size,
      double scale,
      ) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          image: DecorationImage(
            image: AssetImage(path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
