import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isWelcomeView = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      await ref.read(authProvider.notifier).login(email, password);
      
      final state = ref.read(authProvider);
      if (state.status == AuthStatus.authenticated) {
        if (state.role == 'admin') {
          context.go('/admin-dashboard');
        } else {
          context.go('/student-dashboard');
        }
      } else if (state.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? "Authentication failed."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _fillDemo(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Widget _buildRocketIllustration() {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.2), // Glowing purple center
              const Color(0xFF0F1015).withOpacity(0.0), // Fades to background
            ],
            radius: 0.8,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Orbiting stars
            Positioned(
              top: 40,
              left: 60,
              child: Icon(Icons.star, size: 8, color: Colors.indigo.shade300.withOpacity(0.4)),
            ),
            Positioned(
              bottom: 50,
              right: 60,
              child: Icon(Icons.star, size: 10, color: Colors.purple.shade300.withOpacity(0.4)),
            ),
            Positioned(
              top: 100,
              right: 40,
              child: Icon(Icons.star, size: 6, color: Colors.teal.shade300.withOpacity(0.4)),
            ),
            // Floating checkmark card decoration
            Positioned(
              left: 30,
              top: 90,
              child: Container(
                width: 24,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                ),
                child: const Icon(Icons.check, size: 8, color: Colors.greenAccent),
              ),
            ),
            // Floating graph decoration
            Positioned(
              right: 30,
              bottom: 90,
              child: Container(
                width: 24,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                ),
                child: const Icon(Icons.bar_chart_outlined, size: 12, color: Colors.blueAccent),
              ),
            ),
            // Open book at base
            Positioned(
              bottom: 65,
              child: Icon(
                Icons.menu_book,
                size: 64,
                color: Colors.purple.shade400.withOpacity(0.35),
              ),
            ),
            // Rocket lifting off
            Positioned(
              top: 50,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFA78BFA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Icon(
                  Icons.rocket_launch,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraduationIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF7C3AED).withOpacity(0.18),
            const Color(0xFF0F1015).withOpacity(0.0),
          ],
          radius: 0.8,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Icon(Icons.star, size: 6, color: Colors.purple.shade300.withOpacity(0.4)),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Icon(Icons.star, size: 8, color: Colors.indigo.shade300.withOpacity(0.4)),
          ),
          // Book stack base
          Positioned(
            bottom: 24,
            child: Icon(
              Icons.book,
              size: 42,
              color: Colors.indigo.shade400.withOpacity(0.5),
            ),
          ),
          // Graduation Cap
          Positioned(
            top: 24,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFA78BFA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: const Icon(
                Icons.school,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: isDark
                ? [
                    const Color(0xFF13141F), // Deep space grey/navy
                    const Color(0xFF0F1015), // Midnight
                  ]
                : [
                    const Color(0xFFEEF2FF),
                    const Color(0xFFF8FAFC),
                  ],
            radius: 1.5,
            center: Alignment.center,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _isWelcomeView ? _buildWelcomeLayout(context) : _buildLoginFormLayout(context, isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rocket Illustration
        _buildRocketIllustration(),
        const SizedBox(height: 36),

        // Welcome Header
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Welcome to ",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA78BFA)],
              ).createShader(bounds),
              child: const Text(
                "ANHIRE",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Subtext
        Text(
          "Create a student account to unlock mock interviews, aptitude questions, and learning roadmaps tailored for your success.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Create Account Button (Indigo/Purple Gradient)
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: () => context.push('/register'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Toggle link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isWelcomeView = false;
                });
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Color(0xFFA78BFA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginFormLayout(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back Navigation Arrow
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _isWelcomeView = true;
              });
            },
          ),
        ),
        const SizedBox(height: 12),

        // Split Row for Welcome text & illustration
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome back! 👋",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to resume your preparation journey.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            _buildGraduationIllustration(),
          ],
        ),
        const SizedBox(height: 28),

        // Login Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your email address";
                  }
                  if (!value.contains("@")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFFA78BFA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Login Button with Arrow
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _handleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // Google Sign-In button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("Continue with Google"),
                onPressed: isLoading
                    ? null
                    : () async {
                        await ref.read(authProvider.notifier).loginWithGoogle();
                        final state = ref.read(authProvider);
                        if (state.status == AuthStatus.authenticated) {
                          context.go('/student-dashboard');
                        }
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Demo Account Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.06),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(
              color: const Color(0xFF4F46E5).withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Demo Quick Logins (One-Tap):",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.school_outlined, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5).withOpacity(0.12),
                        foregroundColor: const Color(0xFFA78BFA),
                        elevation: 0,
                        minimumSize: const Size(0, 42),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () => _fillDemo("student@placementpro.com", "123456"),
                      label: const Text("Student", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24).withOpacity(0.12),
                        foregroundColor: const Color(0xFFFBBF24),
                        elevation: 0,
                        minimumSize: const Size(0, 42),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () => _fillDemo("admin@placementpro.com", "anandhu@123"),
                      label: const Text("Admin", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "New student? ",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            GestureDetector(
              onTap: () => context.push('/register'),
              child: const Text(
                "Create account",
                style: TextStyle(
                  color: Color(0xFFA78BFA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
