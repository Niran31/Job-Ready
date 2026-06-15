import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!firebaseConfigured) {
        Get.offAllNamed('/home');
        return;
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardColor(context),
      body: Center(
        child: Lottie.asset(
          'assets/lottie/rocket.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const CircularProgressIndicator(color: AppTheme.primary);
          },
        ),
      ),
    );
  }
}
