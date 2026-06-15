import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../services/sync_service.dart';
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
        if (Get.isRegistered<SyncService>()) {
          SyncService.to.syncAll(user.uid);
        }
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
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.work_outline_rounded,
            size: 80,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
