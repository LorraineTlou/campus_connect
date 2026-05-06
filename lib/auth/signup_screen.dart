import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../models/user_model.dart';
import '../reusable/cc_buttons.dart';
import '../reusable/cc_text_fields.dart';
import '../utils/validators.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      // 1. Pre-Firebase Domain Check (Keep the Walled Garden intact)
      String email = _emailController.text.trim().toLowerCase();
      if (!email.endsWith('@students.nust.ac.zw')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must use a valid @students.nust.ac.zw email'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 2. Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // 3. Create the user in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: _passwordController.text.trim(),
            );

        User? user = userCredential.user;

        if (user != null) {
          // Add their full name to their Firebase profile
          await user.updateDisplayName(_nameController.text.trim());

          // Write the user document to Firestore so ProfileScreen can load it
          final newUser = UserModel(
            uid: user.uid,
            name: _nameController.text.trim(),
            username: _nameController.text.trim().toLowerCase().replaceAll(
              RegExp(r'\s+'),
              '',
            ),
            email: email,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap());

          // Sign out so user enters through login flow
          await FirebaseAuth.instance.signOut();

          if (mounted) {
            // Show success dialog
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Account Created!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your account has been created successfully.\nPlease sign in to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Go to Login',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Navigate to Login screen (replace stack)
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Registration failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenInsets,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join your campus community',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                // Full Name Field
                CCTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value != null && value.isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Email Field
                CCTextField(
                  controller: _emailController,
                  label: 'Student Email',
                  hint: 'e.g., n12345678x@students.nust.ac.zw',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // Password Field
                CCPasswordField(
                  controller: _passwordController,
                  label: 'Create Password',
                  hint: 'Enter a strong password',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CCPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                // Sign Up Button
                CCPrimaryButton(
                  label: 'SIGN UP',
                  onPressed: _handleSignUp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // Updated "Sign In" Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                      ), // Pops back to the Login screen
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
