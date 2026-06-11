import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';

class WeeklyReviewHistoryScreen extends StatelessWidget {
  const WeeklyReviewHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Weekly Reviews History'),
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.weeklyReviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_edu_outlined,
                    color: AppTheme.textSecondary,
                    size: 72,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Reviews Logged Yet',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Weekly reviews will show up here after you submit your first Sunday check-in!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final sortedReviews = ctrl.weeklyReviews.toList()
          ..sort((a, b) => b.weekEndDate.compareTo(a.weekEndDate));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedReviews.length,
          itemBuilder: (context, index) {
            final review = sortedReviews[index];
            return _ReviewCard(review: review);
          },
        );
      }),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final WeeklyReviewModel review;
  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  Color _getGradeColor(String g) {
    switch (g) {
      case 'A': return AppTheme.success;
      case 'B': return AppTheme.primary;
      case 'C': return AppTheme.warning;
      default: return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final gradeColor = _getGradeColor(review.grade);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _expanded ? gradeColor.withOpacity(0.5) : AppTheme.bgCardLight,
          width: _expanded ? 1.5 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Grade Badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: gradeColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          review.grade,
                          style: TextStyle(
                            color: gradeColor,
                            fontSize: 20,
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
                            'Week Ending ${review.weekEndDate}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '+${review.grindScoreChange} grind points earned',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable Content
            if (_expanded) ...[
              const Divider(color: AppTheme.bgCardLight, height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Metrics
                    const Text(
                      'Performance Metrics',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _MetricTile(
                          label: 'Applications',
                          value: '${review.applicationsSent}',
                          icon: Icons.send,
                          color: AppTheme.primary,
                        ),
                        _MetricTile(
                          label: 'Interviews',
                          value: '${review.interviewsReceived}',
                          icon: Icons.forum,
                          color: AppTheme.warning,
                        ),
                        _MetricTile(
                          label: 'Study Hours',
                          value: '${review.skillHoursCompleted.toStringAsFixed(1)}h',
                          icon: Icons.bolt,
                          color: AppTheme.success,
                        ),
                        _MetricTile(
                          label: 'Habit Rate',
                          value: '${(review.habitCompletionRate * 100).toStringAsFixed(0)}%',
                          icon: Icons.check_circle,
                          color: AppTheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Strengths & Weaknesses
                    if (review.strengths.isNotEmpty) ...[
                      const Text(
                        'Strengths & Highlights',
                        style: TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ...review.strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_upward, color: AppTheme.success, size: 14),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],

                    if (review.weaknesses.isNotEmpty) ...[
                      const Text(
                        'Areas to Focus / Weaknesses',
                        style: TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ...review.weaknesses.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_downward, color: AppTheme.accent, size: 14),
                            const SizedBox(width: 8),
                            Expanded(child: Text(w, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 16),
                    ],

                    // Reflection Notes
                    if (review.reflectionNotes.isNotEmpty) ...[
                      const Text(
                        'Personal Reflection Notes',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.bgCardLight, width: 1),
                        ),
                        child: Text(
                          review.reflectionNotes,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgCardLight.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
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
