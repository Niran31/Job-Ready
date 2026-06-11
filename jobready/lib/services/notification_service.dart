import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Schedule daily lazy-mode alarm at [hour]:[minute]
  static Future<void> scheduleDailyCheckIn({
    int hour = 10,
    int minute = 0,
  }) async {
    await _plugin.zonedSchedule(
      1,
      '⚠️ Grind check-in',
      "You haven't checked in today. Don't let today be wasted bro!",
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lazy_mode',
          'Lazy Mode Blocker',
          channelDescription: 'Daily accountability check-in',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the daily check-in
  static Future<void> cancelCheckIn() async {
    await _plugin.cancel(1);
  }

  /// Show immediate motivational notification
  static Future<void> showMotivation(String message) async {
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

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
