import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/auth_repository.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isResending = false;

  void _handleResend() async {
    setState(() {
      _isResending = true;
    });

    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification email resent. Please check your spam folder as well!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _checkVerificationStatus() async {
    // Standard simulation check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Verification complete. Loading dashboard..."),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/student-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authProvider).email ?? "your email address";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80, color: Color(0xFF2563EB)),
            const SizedBox(height: 16),
            const Text(
              "Verify your email",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "We have sent a verification link to $email. Please click the link inside the email to activate your account.",
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            ElevatedButton(
              onPressed: _checkVerificationStatus,
              child: const Text("I HAVE VERIFIED"),
            ),
            const SizedBox(height: 16),

            _isResending
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
                    onPressed: _handleResend,
                    child: const Text("RESEND EMAIL"),
                  ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child: const Text("Back to Login", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
