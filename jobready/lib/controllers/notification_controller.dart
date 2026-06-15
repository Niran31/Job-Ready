import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  // Daily Habit Reminder
  final RxBool habitReminderEnabled = true.obs;
  final RxInt habitHour = 20.obs; // 8:00 PM default
  final RxInt habitMinute = 0.obs;

  // Weekly Review Reminder
  final RxBool weeklyReminderEnabled = true.obs;
  final RxInt weeklyDayOfWeek = 7.obs; // Sunday default
  final RxInt weeklyHour = 18.obs; // 6:00 PM default
  final RxInt weeklyMinute = 0.obs;

  // Streak Motivation
  final RxBool streakMotivationEnabled = true.obs;
  final RxInt streakHour = 8.obs; // 8:00 AM default
  final RxInt streakMinute = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    habitReminderEnabled.value = prefs.getBool('habitReminderEnabled') ?? true;
    habitHour.value = prefs.getInt('habitHour') ?? 20;
    habitMinute.value = prefs.getInt('habitMinute') ?? 0;

    weeklyReminderEnabled.value = prefs.getBool('weeklyReminderEnabled') ?? true;
    weeklyDayOfWeek.value = prefs.getInt('weeklyDayOfWeek') ?? 7;
    weeklyHour.value = prefs.getInt('weeklyHour') ?? 18;
    weeklyMinute.value = prefs.getInt('weeklyMinute') ?? 0;

    streakMotivationEnabled.value = prefs.getBool('streakMotivationEnabled') ?? true;
    streakHour.value = prefs.getInt('streakHour') ?? 8;
    streakMinute.value = prefs.getInt('streakMinute') ?? 0;

    // Apply scheduled notifications based on loaded preferences
    _applyHabitReminder();
    _applyWeeklyReminder();
    // Streak will be applied via HabitController which has the streak count
  }

  // ── Updates ────────────────────────────────────────────────────────────────

  Future<void> updateHabitReminder(bool enabled, int hour, int minute) async {
    habitReminderEnabled.value = enabled;
    habitHour.value = hour;
    habitMinute.value = minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('habitReminderEnabled', enabled);
    await prefs.setInt('habitHour', hour);
    await prefs.setInt('habitMinute', minute);

    _applyHabitReminder();
  }

  Future<void> updateWeeklyReminder(bool enabled, int dayOfWeek, int hour, int minute) async {
    weeklyReminderEnabled.value = enabled;
    weeklyDayOfWeek.value = dayOfWeek;
    weeklyHour.value = hour;
    weeklyMinute.value = minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weeklyReminderEnabled', enabled);
    await prefs.setInt('weeklyDayOfWeek', dayOfWeek);
    await prefs.setInt('weeklyHour', hour);
    await prefs.setInt('weeklyMinute', minute);

    _applyWeeklyReminder();
  }

  Future<void> updateStreakMotivation(bool enabled, int hour, int minute, int currentStreak) async {
    streakMotivationEnabled.value = enabled;
    streakHour.value = hour;
    streakMinute.value = minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streakMotivationEnabled', enabled);
    await prefs.setInt('streakHour', hour);
    await prefs.setInt('streakMinute', minute);

    refreshStreakNotification(currentStreak);
  }

  // Called by HabitController whenever streak changes
  Future<void> refreshStreakNotification(int currentStreak) async {
    if (streakMotivationEnabled.value) {
      await NotificationService.scheduleStreakMotivation(
        hour: streakHour.value,
        minute: streakMinute.value,
        streakCount: currentStreak,
      );
    } else {
      await NotificationService.cancelStreakMotivation();
    }
  }

  // ── Internal Appliers ──────────────────────────────────────────────────────

  Future<void> _applyHabitReminder() async {
    if (habitReminderEnabled.value) {
      await NotificationService.scheduleDailyHabitReminder(
        hour: habitHour.value,
        minute: habitMinute.value,
      );
    } else {
      await NotificationService.cancelDailyHabitReminder();
    }
  }

  Future<void> _applyWeeklyReminder() async {
    if (weeklyReminderEnabled.value) {
      await NotificationService.scheduleWeeklyReviewReminder(
        dayOfWeek: weeklyDayOfWeek.value,
        hour: weeklyHour.value,
        minute: weeklyMinute.value,
      );
    } else {
      await NotificationService.cancelWeeklyReviewReminder();
    }
  }
}
