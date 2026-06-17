import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../controllers/habit_controller.dart';
import 'notification_service.dart';

class SmartReminderService {
  static const String _geminiApiKey = 'YOUR_API_KEY';

  Future<String> generateNudgeMessage(int appsSent, int appsTarget, String dayOfWeek) async {
    if (_geminiApiKey == 'YOUR_API_KEY' || _geminiApiKey.isEmpty) {
      return "You are behind on your application targets. Try applying for a job today!";
    }

    final now = DateTime.now();
    final int daysLeft = 7 - now.weekday + 1;
    final int appsNeeded = (appsTarget - appsSent).clamp(0, appsTarget);
    final double appsPerDay = daysLeft > 0 ? (appsNeeded / daysLeft) : 0.0;

    const systemInstruction = "You are a motivational career coach. Generate a short, punchy push notification message (max 100 characters) to motivate a job seeker to apply for jobs today. Be direct, specific, and motivating. No emojis in the text itself. Return ONLY the notification message string, nothing else.";

    final userMessage = '''
Applications sent this week: $appsSent
Weekly target: $appsTarget
Today is: $dayOfWeek
Days left in week: $daysLeft
Apps needed per remaining day to hit target: ${appsPerDay.toStringAsFixed(1)}
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
        systemInstruction: Content.system(systemInstruction),
      );

      final response = await model.generateContent([Content.text(userMessage)]);
      final responseText = response.text?.trim() ?? '';
      if (responseText.isNotEmpty) {
        return responseText;
      }
    } catch (e) {
      debugPrint('Error generating smart reminder nudge: $e');
    }
    return "Don't fall behind on your weekly goals. Apply to some jobs today!";
  }

  Future<void> scheduleSmartReminder() async {
    try {
      // Ensure box is open
      final box = Hive.box<JobModel>('jobs');
      final jobs = box.values.toList();

      int appsTarget = 25;
      int appsSent = 0;

      if (Get.isRegistered<HabitController>()) {
        final ctrl = Get.find<HabitController>();
        appsTarget = ctrl.targetJobs.value;
        appsSent = ctrl.weeklyJobsApplied;
      } else {
        final start = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        final startZero = DateTime(start.year, start.month, start.day);
        appsSent = jobs.where((j) {
          final date = DateTime.tryParse(j.appliedDate);
          if (date == null) return false;
          return !date.isBefore(startZero);
        }).length;
      }

      final now = DateTime.now();
      final List<String> weekdays = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      final String dayOfWeek = weekdays[now.weekday - 1];

      final isBehind = appsSent < (appsTarget * 0.5);

      String body;
      if (isBehind) {
        body = await generateNudgeMessage(appsSent, appsTarget, dayOfWeek);
      } else {
        body = "You're on track this week! Keep the momentum going.";
      }

      await NotificationService.showInstantNotification("JobReady — Stay on Track 🎯", body);
    } catch (e) {
      debugPrint('Error scheduling smart reminder: $e');
    }
  }
}
