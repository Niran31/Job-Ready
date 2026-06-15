import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      _authController.loginWithEmail(
        _emailCtrl.text,
        _passwordCtrl.text,
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  Icon(
                    Icons.work_rounded,
                    size: 64,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue tracking your job hunt',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed('/forgot_password'),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppTheme.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => ElevatedButton(
                        onPressed: _authController.isLoading.value ? null : _login,
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
                                'Login',
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
                          'Sign in with Google',
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
                        "Don't have an account?",
                        style: TextStyle(color: AppTheme.textSecondary(context)),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/signup'),
                        child: Text(
                          'Sign Up',
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
