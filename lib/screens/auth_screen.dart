import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import '../theme_design_system.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool _privacyAccepted = false;

  // RewardBrick logo colors
  final Color bgColor = bgLight;
  final Color lightShadow = highlightColor;
  final Color darkShadow = primaryLightBlue;

  // ----------------------------------------------------------------
  // Google Sign-In
  // ----------------------------------------------------------------
  Future<void> _signInWithGoogle() async {
    if (!_privacyAccepted) {
      _showSnackBar('Please accept the Privacy Policy first.');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn().timeout(const Duration(seconds: 30));
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await http
          .post(
            Uri.parse(
                'https://rewardbrick-api.onrender.com/api/v1/users/google-register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': googleUser.displayName ?? '',
              'email': googleUser.email,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid registration response');
        }
        final user = decoded['user'];
        final userId = user is Map
            ? user['user_id']?.toString()
            : decoded['user_id']?.toString();
        if (userId == null || userId.isEmpty) {
          throw const FormatException('Registration response has no user id');
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);

        if (!mounted) return;
        _showSnackBar(
            'Welcome, ${googleUser.displayName ?? 'to RewardBrick'}!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        String message = 'Registration failed (${response.statusCode}).';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody['message'] != null) {
            message = errorBody['message'].toString();
          }
        } on FormatException {
          // Keep the status-based message when the server returns non-JSON.
        }
        _showSnackBar(message);
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('The server took too long to respond. Please try again.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Unable to sign in. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ----------------------------------------------------------------
  // 2. Neomorphic UI Components (Reusable)
  // ----------------------------------------------------------------
  Widget _neoContainer({required Widget child, double radius = 16}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
              color: lightShadow, offset: const Offset(-8, -8), blurRadius: 15),
          BoxShadow(
              color: darkShadow, offset: const Offset(8, 8), blurRadius: 15),
        ],
      ),
      child: child,
    );
  }

  Widget _neoButton(
      {required VoidCallback onTap,
      required String label,
      required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: lightShadow,
                offset: const Offset(-4, -4),
                blurRadius: 8),
            BoxShadow(
                color: darkShadow, offset: const Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryDarkBlue),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // 3. Main Build
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 210,
                  child: Image.asset(
                    'assets/illustrations/rewardbrick_logo.png',
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.card_giftcard_rounded,
                        size: 100,
                        color: accentPeach),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text('Welcome Back!',
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textDark)),
              const SizedBox(height: 6),
              const Text('Sign in to continue earning with RewardBrick',
                  style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(height: 50),
              _neoContainer(
                child: Column(
                  children: [
                    _neoButton(
                      onTap: _isLoading ? () {} : _signInWithGoogle,
                      label:
                          _isLoading ? 'Connecting...' : 'Continue with Google',
                      icon: Icons.login_rounded,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _privacyAccepted,
                          activeColor: accentCoral,
                          onChanged: (val) =>
                              setState(() => _privacyAccepted = val ?? false),
                        ),
                        const Expanded(
                          child: Text(
                              'I agree to the Privacy Policy and Terms of Service',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
