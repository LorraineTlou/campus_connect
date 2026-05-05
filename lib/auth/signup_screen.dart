import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/app_colors.dart';
import '../base/app_constants.dart';
import '../models/user_model.dart';
import '../reusable/cc_buttons.dart';
import '../reusable/cc_text_fields.dart';
import '../utils/validators.dart';
import '../reusable/campus_main_shell.dart';

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

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account created successfully! Welcome to Campus Connect.',
                ),
                backgroundColor: AppColors.primary,
              ),
            );

            // Navigate directly into the app main feed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CampusMainShell()),
            );
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
