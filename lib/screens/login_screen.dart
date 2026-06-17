import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_learn2/providers/auth_provider.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/screens/register_screen.dart';
import 'package:flutter_learn2/screens/home_screen.dart';
import 'package:flutter_learn2/widgets/ambient_background_painter.dart';
import 'package:flutter_learn2/widgets/login_header.dart';
import 'package:flutter_learn2/widgets/login_form.dart';

/// Login screen with email/password form, fade+slide entrance animation, and a custom radial-gradient background.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Entrance animations (fade + slide up)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Set up fade-in + slide-up entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Validates the form, calls the AuthProvider to log in, then navigates to HomeScreen on success.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Clear navigation stack and go to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Could not connect to server');
    }
  }

  /// Displays a floating red snackbar with the given error message.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              Color(0xFF2D0A00),
              Color(0xFF3D1A00),
              Color(0xFF2D0A00),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        BuildHeader(),
                        const SizedBox(height: 48),
                        LoginForm(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          formKey: _formKey,
                          loading: auth.loading,
                          onLogin: _handleLogin,
                        ),
                        const SizedBox(height: 32),
                        _buildRegisterLink(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the custom radial-gradient background behind the content.
  Widget _buildAnimatedBackground() {
    return const Positioned.fill(
      child: CustomPaint(
        painter: AmbientBackgroundPainter(
          color1: Color(0x26FF5A00),
          color2: Color(0x1FFF9A00),
          color3: Color(0x14FFE808),
        ),
      ),
    );
  }

  /// "Don't have an account? Sign Up" link that navigates to RegisterScreen.
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an iaccount? ",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const RegisterScreen(),
                transitionsBuilder: (_, a, _, child) =>
                    FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.brightAmber,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
