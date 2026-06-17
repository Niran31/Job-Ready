import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/habit_model.dart';
import 'models/sync_queue_model.dart';
import 'models/resume_result_model.dart';
import 'models/job_match_result_model.dart';
import 'controllers/habit_controller.dart';
import 'controllers/notification_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/skills_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/sync_controller.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

bool firebaseConfigured = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase (graceful fallback if config is missing)
  bool firebaseAvailable = false;
  try {
    if (kIsWeb) {
      // For web, Firebase requires options. We skip init if options are missing
      // to avoid crashing the app.
      debugPrint('Firebase on Web requires firebase_options.dart config. Currently running without Firebase on Web.');
    } else {
      // Initialize with generated options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseConfigured = true;
      debugPrint('Firebase initialized successfully.');
    }
  } catch (e) {
    debugPrint('Firebase not configured or initialization failed: $e');
  }

  // Init notifications
  await NotificationService.init();

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(JobModelAdapter());
  Hive.registerAdapter(SkillLogModelAdapter());
  Hive.registerAdapter(WeeklyReviewModelAdapter());
  Hive.registerAdapter(SyncQueueModelAdapter());
  Hive.registerAdapter(ResumeResultModelAdapter());
  Hive.registerAdapter(JobMatchResultModelAdapter());
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<JobModel>('jobs');
  await Hive.openBox<SkillLogModel>('skills');
  await Hive.openBox<WeeklyReviewModel>('weekly_reviews');
  await Hive.openBox<SyncQueueModel>('sync_queue');
  await Hive.openBox<ResumeResultModel>('resume_results');
  await Hive.openBox<JobMatchResultModel>('job_match_results');
  await Hive.openBox('user_profile');

  // Init GetX controller globally
  Get.put(HabitController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(SyncService(), permanent: true);
  Get.put(SyncController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const JobReadyApp());
}

class JobReadyApp extends StatelessWidget {
  const JobReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JobReady',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light mode, can be made dynamic later
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/forgot_password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/home', page: () => const MainNavigation()),
      ],
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    JobsScreen(),
    SkillsScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          border: Border(
            top: BorderSide(
              color: AppTheme.divider(context),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.work_outline,
                  activeIcon: Icons.work_rounded,
                  label: 'Jobs',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.bolt_outlined,
                  activeIcon: Icons.bolt_rounded,
                  label: 'Skills',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected 
                  ? AppTheme.primary 
                  : AppTheme.textSecondary(context),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? AppTheme.primary 
                    : AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
