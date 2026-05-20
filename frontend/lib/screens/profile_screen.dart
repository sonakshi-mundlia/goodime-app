import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '/providers/settings_provider.dart';
import '/providers/auth_provider.dart';
import '/providers/language_service.dart';
import '../main.dart';

String t(String key) => LanguageService.t(key);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool editOpen = false;
  bool languageOpen = false;
  bool themeOpen = false;
  bool helpOpen = false;
  bool termsOpen = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
    );

  }

  // ================= UI HELPERS =================
  Widget divider() => const Divider(height: 1);

  Widget toggleIcon(bool open) {
    return Icon(
      open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
    );
  }

  // ================= HEADER =================
  Widget userHeader(AuthProvider auth) {
    final name = auth.userName?.isNotEmpty == true
        ? auth.userName!
        : "Guest User";

    final email = auth.userEmail?.isNotEmpty == true
        ? auth.userEmail!
        : "Not logged in";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 42, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ================= TILE =================
  Widget buildTile({
    required IconData icon,
    required String title,
    required bool open,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: toggleIcon(open),
          onTap: onTap,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
          crossFadeState:
          open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
        divider(),
      ],
    );
  }

  // ================= LANGUAGE =================
  Widget languageSection(SettingsProvider settings) {
    return Column(
      children: settings.languages.map((lang) {
        return ListTile(
          dense: true,
          title: Text(lang["name"]!),
          trailing: settings.languageCode == lang["code"]
              ? const Icon(Icons.check, color: Colors.green)
              : null,
          onTap: () => settings.setLanguage(lang["code"]!),
        );
      }).toList(),
    );
  }

  // ================= THEME =================
  Widget themeSection(SettingsProvider settings) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: const Text("Light"),
          trailing: settings.themeModeName == "Light"
              ? Icon(Icons.check, color: Colors.green.shade800)
              : null,
          onTap: () => settings.setTheme("Light"),
        ),
        ListTile(
          dense: true,
          title: const Text("Dark"),
          trailing: settings.themeModeName == "Dark"
              ? Icon(Icons.check, color: Colors.green.shade400)
              : null,
          onTap: () => settings.setTheme("Dark"),
        ),
      ],
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t("profile")),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            userHeader(auth),
            divider(),

            // ================= EDIT PROFILE =================
            buildTile(
              icon: Icons.edit,
              title: t("edit_profile"),
              open: editOpen,
              onTap: () {
                nameController.text = auth.userName ?? "";
                emailController.text = auth.userEmail ?? "";

                setState(() => editOpen = !editOpen);
              },
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: t("name")),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: t("email")),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newEmail = emailController.text.trim();

                        final currentName = auth.userName ?? "";
                        final currentEmail = auth.userEmail ?? "";

                        // nothing changed
                        if (newName == currentName &&
                            newEmail == currentEmail) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t("no_changes_to_update")),
                            ),
                          );
                          return;
                        }

                        // empty validation
                        if (newName.isEmpty && newEmail.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                              Text(t("please_enter_name_or_email")),
                            ),
                          );
                          return;
                        }

                        try {
                          await auth.updateProfile(
                            name: newName.isEmpty ? null : newName,
                            email: newEmail.isEmpty ? null : newEmail,
                          );

                          if (!mounted) return;

                          setState(() => editOpen = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("profile_updated_successfully"),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Update failed: $e")),
                          );
                        }
                      },
                      child: Text(t("save")),
                    ),
                  ),
                ],
              ),
            ),

            // ================= LANGUAGE =================
            buildTile(
              icon: Icons.language,
              title: t("language"),
              open: languageOpen,
              onTap: () => setState(() => languageOpen = !languageOpen),
              child: languageSection(settings),
            ),

            // ================= THEME =================
            buildTile(
              icon: Icons.dark_mode,
              title: t("theme"),
              open: themeOpen,
              onTap: () => setState(() => themeOpen = !themeOpen),
              child: themeSection(settings),
            ),

            // ================= HELP =================
            buildTile(
              icon: Icons.help,
              title: t("help_support"),
              open: helpOpen,
              onTap: () => setState(() => helpOpen = !helpOpen),
              child: Text(t("help_text")),
            ),

            // ================= TERMS =================
            buildTile(
              icon: Icons.description,
              title: t("terms_conditions"),
              open: termsOpen,
              onTap: () => setState(() => termsOpen = !termsOpen),
              child: Text(t("terms_text")),
            ),

            // ================= LOGOUT =================
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(t("logout")),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }
}
