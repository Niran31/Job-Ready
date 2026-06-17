import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../controllers/weekly_review_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/saas_card.dart';
import '../widgets/saas_button.dart';

class WeeklyReviewDialog extends StatefulWidget {
  const WeeklyReviewDialog({super.key});

  @override
  State<WeeklyReviewDialog> createState() => _WeeklyReviewDialogState();
}

class _WeeklyReviewDialogState extends State<WeeklyReviewDialog> {
  final _reflectionCtrl = TextEditingController();
  final _strengthsCtrl = TextEditingController();
  final _weaknessesCtrl = TextEditingController();
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

    // Initialize controller inputs
    _strengthsCtrl.text = strengths.join('\n');
    _weaknessesCtrl.text = weaknesses.join('\n');

    // Bind inputs to updates from AI Controller
    final aiCtrl = Get.put(WeeklyReviewController());
    aiCtrl.grade.value = grade;
    aiCtrl.aiSuggestion.value = '';

    aiCtrl.strengthsText.listen((val) {
      if (_strengthsCtrl.text != val) {
        _strengthsCtrl.text = val;
      }
    });
    aiCtrl.weaknessesText.listen((val) {
      if (_weaknessesCtrl.text != val) {
        _weaknessesCtrl.text = val;
      }
    });
    aiCtrl.reflectionText.listen((val) {
      if (_reflectionCtrl.text != val) {
        _reflectionCtrl.text = val;
      }
    });
  }

  @override
  void dispose() {
    _reflectionCtrl.dispose();
    _strengthsCtrl.dispose();
    _weaknessesCtrl.dispose();
    // Delete the controller when dialog closes
    Get.delete<WeeklyReviewController>();
    super.dispose();
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
    if (apps >= targetApps) list.add('Met or exceeded job application target (+$apps)');
    if (hours >= targetHours) list.add('Exceeded weekly study target (${hours.toStringAsFixed(1)}h)');
    if (habitRate >= 0.8) list.add('Excellent habit consistency (${(habitRate * 100).toStringAsFixed(0)}%)');
    if (apps > 5 && hours > 10) list.add('Balanced routine between job hunt and study');
    if (list.isEmpty) list.add('Stayed active and kept logging progress');
    return list.take(3).toList();
  }

  List<String> _getWeaknesses() {
    final list = <String>[];
    if (apps < targetApps * 0.6) list.add('Job applications are low ($apps/$targetApps)');
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
    final aiCtrl = Get.find<WeeklyReviewController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SaasCard(
        padding: const EdgeInsets.all(24),
        borderColor: AppTheme.primary.withOpacity(0.2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Career Review',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textSecondary(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Auto-Fill Card
              Obx(() => _buildAiAutoFillCard(context, aiCtrl)),
              
              // Dynamic AI Suggestion Tip Card
              Obx(() {
                if (aiCtrl.aiSuggestion.value.isNotEmpty) {
                  return _buildAiSuggestionCard(context, aiCtrl.aiSuggestion.value);
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 24),

              // Grade Card
              Obx(() {
                final currentGrade = aiCtrl.grade.value;
                final gradeColor = _getGradeColor(currentGrade);
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradeColor.withOpacity(0.15),
                        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gradeColor.withOpacity(0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: gradeColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            currentGrade,
                            style: TextStyle(
                              color: gradeColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Grade: ${_getGradeLabel(currentGrade)}',
                              style: TextStyle(
                                color: AppTheme.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Grind score earned: +$grindScoreChange pts',
                            style: TextStyle(
                              color: AppTheme.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Grade Dropdown Selector
            Obx(() => DropdownButtonFormField<String>(
              value: aiCtrl.grade.value,
              dropdownColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              decoration: InputDecoration(
                labelText: 'Adjust Weekly Grade',
                filled: true,
                fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
                ),
              ),
              items: ['A', 'B', 'C', 'D', 'F'].map((g) => DropdownMenuItem(
                value: g,
                child: Text(g, style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold)),
              )).toList(),
              onChanged: (val) {
                if (val != null) aiCtrl.grade.value = val;
              },
            )),
            const SizedBox(height: 24),

            // Progress Review Rows
            Text(
              'Weekly Performance vs Targets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),

            // Strengths & Weaknesses Inputs
            Text(
              'Strengths & Highlights (one per line)',
              style: TextStyle(
                color: AppTheme.success,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _strengthsCtrl,
              maxLines: 3,
              style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter your strengths this week...',
                fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Areas to Focus / Weaknesses (one per line)',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weaknessesCtrl,
              maxLines: 3,
              style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter areas to focus or weaknesses...',
                fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Personal Reflection
            Text(
              'Personal Reflection Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reflectionCtrl,
              maxLines: 3,
              style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write down what went well, what blocked you, and your plan for next week...',
                fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SaasButton(
              text: 'Submit Weekly Review',
              width: double.infinity,
              onPressed: () {
                final finalStrengths = _strengthsCtrl.text
                    .split('\n')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                final finalWeaknesses = _weaknessesCtrl.text
                    .split('\n')
                    .map((w) => w.trim())
                    .where((w) => w.isNotEmpty)
                    .toList();

                _ctrl.saveWeeklyReview(
                  _reflectionCtrl.text.trim(),
                  aiCtrl.grade.value,
                  finalStrengths.isEmpty ? ['Stayed active and kept logging progress'] : finalStrengths,
                  finalWeaknesses.isEmpty ? ['No major weaknesses. Keep up the high standard!'] : finalWeaknesses,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Weekly review logged successfully! Grade: ${aiCtrl.grade.value} 🎉'),
                    backgroundColor: AppTheme.cardColor(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAiAutoFillCard(BuildContext context, WeeklyReviewController aiCtrl) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Auto-Fill',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Generate your review from this week's activity",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: aiCtrl.isGenerating.value ? null : aiCtrl.generateAiReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: aiCtrl.isGenerating.value
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Analyzing your week...',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      )
                    : const Text(
                        'Generate with AI ✨',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiSuggestionCard(BuildContext context, String suggestion) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Tip for Next Week',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isMet ? AppTheme.success : AppTheme.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isMet ? Icons.check_circle_rounded : Icons.pending_rounded,
                color: isMet ? AppTheme.success : AppTheme.textSecondary(context).withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
