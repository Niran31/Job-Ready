import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../theme/app_theme.dart';

class WeeklyReviewDialog extends StatefulWidget {
  const WeeklyReviewDialog({super.key});

  @override
  State<WeeklyReviewDialog> createState() => _WeeklyReviewDialogState();
}

class _WeeklyReviewDialogState extends State<WeeklyReviewDialog> {
  final _reflectionCtrl = TextEditingController();
  final _ctrl = Get.find<HabitController>();

  late final int apps;
  late final double hours;
  late final double habitRate;
  late final int targetApps;
  late final double targetHours;
  late final int targetCoding;
  late final int targetDsa;
  late final int codingSessions;
  late final int dsaSessions;
  late final int grindScoreChange;

  late final String grade;
  late final List<String> strengths;
  late final List<String> weaknesses;

  @override
  void initState() {
    super.initState();
    apps = _ctrl.weeklyJobsApplied;
    hours = _ctrl.weeklySkillHours;
    habitRate = _ctrl.weeklyHabitCompletionRate;
    targetApps = _ctrl.targetJobs.value;
    targetHours = _ctrl.targetHours.value;
    targetCoding = _ctrl.targetCoding.value;
    targetDsa = _ctrl.targetDsa.value;
    codingSessions = _ctrl.weeklyCodingSessions;
    dsaSessions = _ctrl.weeklyDsaSessions;
    grindScoreChange = _ctrl.weeklyGrindScoreEarned;

    grade = _calculateGrade();
    strengths = _getStrengths();
    weaknesses = _getWeaknesses();
  }

  String _calculateGrade() {
    double appScore = targetApps == 0 ? 1.0 : (apps / targetApps).clamp(0.0, 1.0);
    double hourScore = targetHours == 0.0 ? 1.0 : (hours / targetHours).clamp(0.0, 1.0);
    double score = (appScore * 0.4) + (hourScore * 0.4) + (habitRate * 0.2);

    if (score >= 0.85) return 'A';
    if (score >= 0.70) return 'B';
    if (score >= 0.50) return 'C';
    return 'D';
  }

  List<String> _getStrengths() {
    final list = <String>[];
    if (apps >= targetApps) list.add('Met or exceeded job application target (+${apps})');
    if (hours >= targetHours) list.add('Exceeded weekly study target (${hours.toStringAsFixed(1)}h)');
    if (habitRate >= 0.8) list.add('Excellent habit consistency (${(habitRate * 100).toStringAsFixed(0)}%)');
    if (apps > 5 && hours > 10) list.add('Balanced routine between job hunt and study');
    if (list.isEmpty) list.add('Stayed active and kept logging progress');
    return list.take(3).toList();
  }

  List<String> _getWeaknesses() {
    final list = <String>[];
    if (apps < targetApps * 0.6) list.add('Job applications are low (${apps}/${targetApps})');
    if (hours < targetHours * 0.6) list.add('Study time is below target (${hours.toStringAsFixed(1)}/${targetHours}h)');
    if (habitRate < 0.5) list.add('Habit completion rate is low (${(habitRate * 100).toStringAsFixed(0)}%)');
    if (apps == 0) list.add('Zero job applications sent. Need to apply daily!');
    if (hours == 0) list.add('No skill study logged this week');
    if (list.isEmpty) list.add('No major weaknesses. Keep up the high standard!');
    return list.take(3).toList();
  }

  Color _getGradeColor(String g) {
    switch (g) {
      case 'A': return AppTheme.success;
      case 'B': return AppTheme.primary;
      case 'C': return AppTheme.warning;
      default: return AppTheme.accent;
    }
  }

  String _getGradeLabel(String g) {
    switch (g) {
      case 'A': return 'Excellent';
      case 'B': return 'Good';
      case 'C': return 'Average';
      default: return 'Needs Improvement';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor(grade);

    return Dialog(
      backgroundColor: AppTheme.bgDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weekly Career Review',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grade Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradeColor.withOpacity(0.25),
                      AppTheme.bgCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gradeColor.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: gradeColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          grade,
                          style: TextStyle(
                            color: gradeColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Grade: ${_getGradeLabel(grade)}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Grind score earned: +$grindScoreChange pts',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress Review Rows
              const Text(
                'Weekly Performance vs Targets',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ReviewStatRow(
                label: '📨 Job applications',
                value: '$apps / $targetApps',
                isMet: apps >= targetApps,
              ),
              _ReviewStatRow(
                label: '⚡ Study hours completed',
                value: '${hours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(0)}h',
                isMet: hours >= targetHours,
              ),
              _ReviewStatRow(
                label: '💻 Coding sessions',
                value: '$codingSessions / $targetCoding',
                isMet: codingSessions >= targetCoding,
              ),
              _ReviewStatRow(
                label: '🧠 DSA sessions',
                value: '$dsaSessions / $targetDsa',
                isMet: dsaSessions >= targetDsa,
              ),
              _ReviewStatRow(
                label: '✅ Habit completion rate',
                value: '${(habitRate * 100).toStringAsFixed(0)}%',
                isMet: habitRate >= 0.75,
              ),
              const SizedBox(height: 20),

              // Strengths & Weaknesses
              const Text(
                'Strengths & Highlights',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...strengths.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_upward, color: AppTheme.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              const Text(
                'Areas to Focus / Weaknesses',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...weaknesses.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_downward, color: AppTheme.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(w, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                  ],
                ),
              )),
              const SizedBox(height: 20),

              // Personal Reflection
              const Text(
                'Personal Reflection Notes',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reflectionCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write down what went well, what blocked you, and your plan for next week...',
                  fillColor: AppTheme.bgCard,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _ctrl.saveWeeklyReview(
                      _reflectionCtrl.text.trim(),
                      grade,
                      strengths,
                      weaknesses,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Weekly review for Sunday logged successfully! Grade: $grade 🎉'),
                        backgroundColor: AppTheme.bgCard,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Weekly Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMet;

  const _ReviewStatRow({
    required this.label,
    required this.value,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isMet ? AppTheme.success : AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isMet ? Icons.check_circle : Icons.pending,
                color: isMet ? AppTheme.success : AppTheme.textSecondary.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
