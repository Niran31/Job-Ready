import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const int _habitId = 1;
  static const int _weeklyId = 2;
  static const int _streakId = 3;

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      debugPrint('Failed to get local timezone: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // Request permissions for Android 13+
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  // ── Daily Habit Reminder ───────────────────────────────────────────────────

  static Future<void> scheduleDailyHabitReminder({
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    await _plugin.zonedSchedule(
      _habitId,
      '🎯 Time to grind!',
      "Don't let today be a zero day. Log your habits!",
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminder_channel',
          'Habit Reminders',
          channelDescription: 'Daily reminder to log your habits',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );
  }

  static Future<void> cancelDailyHabitReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(_habitId);
  }

  // ── Weekly Review Reminder ─────────────────────────────────────────────────

  static Future<void> scheduleWeeklyReviewReminder({
    required int dayOfWeek, // 1 = Mon, 7 = Sun
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    await _plugin.zonedSchedule(
      _weeklyId,
      '📊 Weekly Review Time',
      "Reflect on your progress and plan the upcoming week.",
      _nextInstanceOfWeekdayTime(dayOfWeek, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_review_channel',
          'Weekly Review Reminders',
          channelDescription: 'Reminder to complete your weekly review',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Repeats weekly
    );
  }

  static Future<void> cancelWeeklyReviewReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(_weeklyId);
  }

  // ── Motivational Streak Reminder ───────────────────────────────────────────

  static Future<void> scheduleStreakMotivation({
    required int hour,
    required int minute,
    required int streakCount,
  }) async {
    if (kIsWeb) return;
    final message = streakCount > 0
        ? "You're on a $streakCount day streak! Keep the momentum going! 🔥"
        : "Every great streak starts with day 1. Let's get it today! 💪";

    await _plugin.zonedSchedule(
      _streakId,
      '🚀 Keep pushing!',
      message,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_motivation_channel',
          'Streak Motivation',
          channelDescription: 'Daily motivation and streak updates',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );
  }

  static Future<void> cancelStreakMotivation() async {
    if (kIsWeb) return;
    await _plugin.cancel(_streakId);
  }

  // ── Immediate Generic Motivation ───────────────────────────────────────────

  static Future<void> showMotivation(String message) async {
    if (kIsWeb) return;
    await _plugin.show(
      0,
      '🔥 JobReady',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivation',
          channelDescription: 'Daily motivation',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  }

  // ── Smart Reminder Nudge Notification ──────────────────────────────────────

  static Future<void> showInstantNotification(String title, String body) async {
    if (kIsWeb) return;
    await _plugin.show(
      99,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'smart_reminder_channel',
          'Smart Reminders',
          channelDescription: 'Smart job application nudge reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextInstanceOfWeekdayTime(
      int dayOfWeek, int hour, int minute) {
    tz.TZDateTime scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != dayOfWeek) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
