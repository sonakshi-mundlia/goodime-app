import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'history_detail_screen.dart';
import '/providers/settings_provider.dart';
import '/providers/auth_provider.dart';
import '/providers/language_service.dart';

String t(String key) => LanguageService.t(key);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = true;
  List history = [];

  final String baseUrl = "https://goodime-app.onrender.com";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchHistory();
    });
  }

  // ================= FETCH HISTORY =================
  Future<void> fetchHistory() async {
    try {
      setState(() => loading = true);

      final auth = context.read<AuthProvider>();
      final token = auth.token;

      // ================= TOKEN CHECK =================
      if (token == null || token.isEmpty) {
        throw Exception("User not logged in - token missing");
      }

      // ================= API CALL =================
      final res = await http.get(
        Uri.parse("$baseUrl/history"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // ================= AUTH ERROR =================
      if (res.statusCode == 401) {
        throw Exception("Unauthorized - Invalid token");
      }

      if (res.statusCode != 200) {
        throw Exception("Server error: ${res.statusCode}");
      }

      final data = jsonDecode(res.body);

      if (!mounted) return;

      // ================= SAFE PARSING =================
      List parsedHistory = [];

      if (data is List) {
        parsedHistory = data;
      } else if (data is Map) {
        parsedHistory = data["data"] ??
            data["history"] ??
            [];
      }

      setState(() {
        history = parsedHistory;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ================= DELETE =================
  Future<void> deleteHistory(String id) async {
    try {
      final token = context.read<AuthProvider>().token;

      if (token == null || token.isEmpty) {
        throw Exception("User not logged in");
      }

      final res = await http.delete(
        Uri.parse("$baseUrl/history/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        if (!mounted) return;

        setState(() {
          history.removeWhere((item) => item["_id"] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t("deleted_successfully")),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final size = MediaQuery.of(context).size;

    final isSmall = size.width < 360;
    final isLarge = size.width >= 700;

    final padding = isLarge ? 20.0 : isSmall ? 10.0 : 12.0;
    final titleSize = isLarge ? 18.0 : isSmall ? 14.0 : 16.0;
    final bodySize = isLarge ? 14.5 : isSmall ? 12.0 : 13.5;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t("history")),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchHistory,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : history.isEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Text(
            t("no_history_found"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: titleSize),
          ),
        ),
      )

      // ================= LIST =================
          : ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final id = item["_id"];

          return Dismissible(
            key: Key(id),
            direction: DismissDirection.endToStart,

            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: color.error,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),

            onDismissed: (_) => deleteHistory(id),

            child: Container(
              margin: EdgeInsets.only(bottom: isLarge ? 14 : 10),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.outlineVariant,
                ),
              ),

              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryDetailScreen(
                        fileName: item["fileName"] ?? "Untitled",
                        summary: item["summary"] ?? "",
                        date: item["createdAt"] ?? item["date"] ?? "",
                      ),
                    ),
                  );
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: isSmall ? 8 : 10,
                ),

                title: Text(
                  item["fileName"] ?? "Untitled",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    Text(
                      item["summary"] ?? "",
                      maxLines: isLarge ? 4 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: bodySize,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      item["createdAt"] ??
                          item["date"] ??
                          "",
                      style: TextStyle(
                        fontSize: isSmall ? 10.5 : 12,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: color.error,
                  ),
                  onPressed: () => deleteHistory(id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
