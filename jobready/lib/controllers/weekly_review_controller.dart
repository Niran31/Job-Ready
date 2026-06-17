import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'habit_controller.dart';
import '../services/weekly_review_ai_service.dart';

class WeeklyReviewController extends GetxController {
  final RxBool isGenerating = false.obs;
  final RxString aiSuggestion = ''.obs;

  // Form Fields
  final RxString grade = 'C'.obs;
  final RxString strengthsText = ''.obs;
  final RxString weaknessesText = ''.obs;
  final RxString reflectionText = ''.obs;

  Future<void> generateAiReview() async {
    final habitController = Get.find<HabitController>();

    final int apps = habitController.weeklyJobsApplied;
    final int targetApps = habitController.targetJobs.value;
    final double skillHours = habitController.weeklySkillHours;
    final double targetSkillHours = habitController.targetHours.value;
    
    // Count habit logs completed this week
    int habitsCompleted = 0;
    final start = habitController.startOfWeek();
    final today = DateTime.now();
    for (final h in habitController.habits) {
      for (final d in h.completedDates) {
        final date = DateTime.tryParse(d);
        if (date != null && !date.isBefore(start) && !date.isAfter(today)) {
          habitsCompleted++;
        }
      }
    }

    final int totalHabits = habitController.habits.length;
    final int codingSessions = habitController.weeklyCodingSessions;

    // Count interviews scheduled this week
    final int interviewsReceived = habitController.jobs.where((j) {
      final date = DateTime.tryParse(j.appliedDate);
      if (date == null || date.isBefore(start)) return false;
      return j.status == 'interview';
    }).length;

    final String weekEndDate = habitController.lastSundayKey;

    // Gracefully handle empty week data
    if (apps == 0 && skillHours == 0.0 && habitsCompleted == 0) {
      Get.snackbar(
        'No Activity Found',
        'No activity data found for this week. Add some logs first!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final weekData = {
      'applicationsSent': apps,
      'targetApplications': targetApps,
      'skillHours': skillHours,
      'targetSkillHours': targetSkillHours,
      'habitsCompleted': habitsCompleted,
      'totalHabits': totalHabits,
      'codingSessions': codingSessions,
      'interviewsReceived': interviewsReceived,
      'weekEndDate': weekEndDate,
    };

    try {
      isGenerating.value = true;

      final reviewResult = await WeeklyReviewAiService.generateReview(weekData);

      // Auto-populate form fields
      grade.value = reviewResult['grade'] ?? 'C';
      strengthsText.value = reviewResult['strengths'] ?? '';
      weaknessesText.value = reviewResult['weaknesses'] ?? '';
      reflectionText.value = reviewResult['reflection'] ?? '';
      aiSuggestion.value = reviewResult['suggestion'] ?? '';

      Get.snackbar(
        '✨ Review generated!',
        'Review and save your weekly assessment.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('AI Weekly Review Error: $e');
      Get.snackbar(
        'AI Generation Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGenerating.value = false;
    }
  }
}
