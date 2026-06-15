import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  void _signup() {
    if (_formKey.currentState!.validate()) {
      _authController.signupWithEmail(
        _nameCtrl.text,
        _emailCtrl.text,
        _passwordCtrl.text,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary(context)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email is required';
                      if (!GetUtils.isEmail(val)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                      prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password is required';
                      if (val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: true,
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                      prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Confirm your password';
                      if (val != _passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Obx(() => ElevatedButton(
                        onPressed: _authController.isLoading.value ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _authController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.divider(context))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: AppTheme.textSecondary(context))),
                      ),
                      Expanded(child: Divider(color: AppTheme.divider(context))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(() => OutlinedButton.icon(
                        onPressed: _authController.isLoading.value ? null : () => _authController.signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: AppTheme.divider(context)),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: Text(
                          'Sign up with Google',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: AppTheme.textSecondary(context)),
                      ),
                      TextButton(
                        onPressed: () => Get.back(), // Navigates back to login
                        child: Text(
                          'Login',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
