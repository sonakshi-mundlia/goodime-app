import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '/providers/settings_provider.dart';
import '/providers/language_service.dart';

String t(String key) => LanguageService.t(key);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  final String baseUrl = "https://goodime-app.onrender.com";

  // ================= REGISTER =================
  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("fill_all_fields"))),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("weak_password"))),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final token = data["token"];

        await context.read<AuthProvider>().login(
          token,
          name: name,
          email: email,
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["error"] ?? data["message"] ?? "Register failed"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ================= UI CARD =================
  Widget buildFormCard(double boxWidth, double padding, double titleSize, double fieldFont, double buttonHeight) {
    return Container(
      width: boxWidth,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add_alt_1,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 12),

          Text(
            t("create_account"),
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 26),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: t("name"),
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // EMAIL
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: t("email"),
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // PASSWORD
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: t("password"),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => hidePassword = !hidePassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // BUTTON
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
                  : Text(
                t("create_account"),
                style: TextStyle(
                  fontSize: fieldFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    final size = MediaQuery.of(context).size;

    final small = size.width < 360;
    final large = size.width >= 900;

    final padding = large ? 32.0 : 20.0;
    final boxWidth = large ? 500.0 : 420.0;

    final titleSize = large ? 30.0 : small ? 24.0 : 26.0;
    final fieldFont = large ? 16.0 : 14.0;
    final buttonHeight = large ? 56.0 : 50.0;


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        centerTitle: true,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: buildFormCard(
              boxWidth,
              padding,
              titleSize,
              fieldFont,
              buttonHeight,
            ),
          ),
        ),
      ),
    );
  }
}
