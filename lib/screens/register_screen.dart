import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_learn2/providers/auth_provider.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/screens/home_screen.dart';

/// Registration screen with name, email, password, and confirm-password fields,
/// fade+slide entrance animation, and a custom radial-gradient background.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Toggle password visibility for both password fields
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
        parent: _animationController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Validates form, calls AuthProvider.register, navigates to HomeScreen on success.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().register(
            _nameController.text.trim(),
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
            Positioned.fill(
                child: CustomPaint(painter: _BackgroundPainter())),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildBackButton(),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 36),
                        _buildRegisterCard(auth.loading),
                        const SizedBox(height: 28),
                        _buildLoginLink(),
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

  /// Back button with frosted-glass style container.
  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  /// App icon, "Create Account" title, and "Join us" subtitle.
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.amberGlow, AppColors.sunbeamYellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.amberGlow.withValues(alpha: 0.4),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.person_add_rounded,
              color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
          ).createShader(bounds),
          child: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join us and get started',
          style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              letterSpacing: 0.2),
        ),
      ],
    );
  }

  /// Semi-transparent card containing the registration form fields and submit button.
  Widget _buildRegisterCard(bool loading) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: AppColors.amberGlow.withValues(alpha: 0.08),
              blurRadius: 40),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(
              label: 'Full Name',
              hint: 'John Doe',
              icon: Icons.person_outline,
              controller: _nameController,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 18),
            _buildField(
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildField(
              label: 'Password',
              hint: 'Minimum 6 characters',
              icon: Icons.lock_outline,
              controller: _passwordController,
              obscure: _obscurePassword,
              suffix: IconButton(
                icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildField(
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              icon: Icons.lock_outline,
              controller: _confirmPasswordController,
              obscure: _obscureConfirm,
              suffix: IconButton(
                icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildRegisterButton(loading),
          ],
        ),
      ),
    );
  }

  /// Reusable form field with label, hint, icon, and optional visibility toggle.
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
            prefixIcon:
                Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: AppColors.amberGlow, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.red, width: 1.5),
            ),
            errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  /// Gradient "Create Account" button that shows a spinner while loading.
  Widget _buildRegisterButton(bool loading) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: loading
            ? null
            : const LinearGradient(
                colors: [AppColors.amberGlow, AppColors.brightAmber],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: loading ? Colors.white.withValues(alpha: 0.1) : null,
        boxShadow: loading
            ? []
            : [
                BoxShadow(
                  color: AppColors.amberGlow.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : _handleRegister,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.brightAmber),
                  )
                : const Text('Create Account',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  /// "Already have an account? Sign In" link that pops back to LoginScreen.
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('Sign In',
              style: TextStyle(
                  color: AppColors.brightAmber,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

/// Draws overlapping radial gradient circles for the register screen's background effect.
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.amberGlow.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.1),
        radius: size.width * 0.7,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.1), size.width * 0.7, paint1);

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.blazeOrange.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.75),
        radius: size.width * 0.55,
      ));
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75),
        size.width * 0.55, paint2);

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.sunbeamYellow.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.5),
        radius: size.width * 0.4,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.4, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
