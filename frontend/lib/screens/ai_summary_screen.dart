import 'dart:async';
import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class AISummaryScreen extends StatefulWidget {
  final String fileName;
  final String summary;

  const AISummaryScreen({
    super.key,
    required this.fileName,
    required this.summary,
  });

  @override
  State<AISummaryScreen> createState() => _AISummaryScreenState();
}

class _AISummaryScreenState extends State<AISummaryScreen> {
  String streamed = "";
  int index = 0;
  Timer? timer;
  bool done = false;

  bool isLoading = false;

  List<Map<String, String>> history = [];
  String currentSummary = "";

  @override
  void initState() {
    super.initState();
    _startStream(widget.summary, widget.fileName);
  }

  // ================= STREAM =================
  void _startStream(String summary, String fileName) {
    timer?.cancel();

    setState(() {
      streamed = "";
      index = 0;
      done = false;
    });

    timer = Timer.periodic(const Duration(milliseconds: 18), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (index < summary.length) {
        streamed += summary[index];
        index++;

        if (index % 3 == 0) setState(() {});
      } else {
        setState(() => done = true);
        t.cancel();

        currentSummary = summary;

        history.insert(0, {
          "file": fileName,
          "summary": summary,
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= PICK FILE =================
  Future<void> pickFile() async {
    if (!done) return;

    setState(() => isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception("No file bytes found");
      }

      // extract text
      final extractedText = await extractPdfText(file.bytes!);


      if (extractedText.trim().isEmpty) {
        throw Exception("Could not extract text from PDF");
      }

      // GET USER LANGUAGE FROM FRONTEND
      final lang = context.read<SettingsProvider>().languageCode;

      // CALL BACKEND (RECOMMENDED)
      final summary = await generateAISummary(extractedText, lang);

      // START STREAM WITH NEW DATA
      _startStream(summary, file.name);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= PDF EXTRACTION =================
  Future<String> extractPdfText(List<int> bytes) async {
    try {
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      return "";
    }
  }

  // ================= AI (MOCK) =================
  Future<String> generateAISummary(String text, String language) async {
    return "Summary:\n$text\n\nKey Findings:\nAI processed content successfully.";
  }

  // ================= PDF =================

  Future<File> generatePdf({
    required String title,
    required String summary,
  }) async {
    final pdf = pw.Document();

    final font = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Paragraph(
            text: summary,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    // safe file name (no spaces / symbols)
    final safeTitle = title
        .toLowerCase()
        .replaceAll(" ", "-")
        .replaceAll(RegExp(r'[^\w\-]'), '');

    final file = File("${dir.path}/$safeTitle-summary.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> downloadPdf(String title, String summary) async {
    final file = await generatePdf(
      title: title,
      summary: summary,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF saved: ${file.path}")),
    );
  }

  Future<void> sharePdf(String title, String summary) async {
    final file = await generatePdf(
      title: title,
      summary: summary,
    );

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "AI Generated Summary",
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final small = size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Session"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: small ? 10 : 16,
                vertical: 10,
              ),
              children: [
                if (!done)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Text(
                      streamed + "▋",
                      style: const TextStyle(height: 1.5),
                    ),
                  ),

                const SizedBox(height: 20),

                ...history.map(
                      (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["file"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(item["summary"]!),
                      const Divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (currentSummary.isNotEmpty)
                              ? () {
                            downloadPdf(widget.fileName, currentSummary);
                          }
                              : null,
                          icon: const Icon(Icons.download),
                          label: const Text("Download"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (currentSummary.isNotEmpty)
                              ? () {
                            sharePdf(widget.fileName, currentSummary);
                          }
                              : null,
                          icon: const Icon(Icons.share),
                          label: const Text("Share"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: (done && !isLoading) ? pickFile : null,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        done ? "Upload Another File" : "Processing...",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
