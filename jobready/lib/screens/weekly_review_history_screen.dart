import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class WeeklyReviewHistoryScreen extends StatelessWidget {
  const WeeklyReviewHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Reviews History'),
      ),
      body: Obx(() {
        if (ctrl.weeklyReviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_edu_rounded,
                    color: AppTheme.textSecondary(context),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Reviews Logged Yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Weekly reviews will show up here after you submit your first Sunday check-in!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        final sortedReviews = ctrl.weeklyReviews.toList()
          ..sort((a, b) => b.weekEndDate.compareTo(a.weekEndDate));

        return ListView.builder(
          padding: const EdgeInsets.all(24),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _expanded ? gradeColor.withOpacity(0.5) : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
          width: _expanded ? 1.5 : 1.0,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Grade Badge
                    Container(
                      width: 56,
                      height: 56,
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
                            fontSize: 24,
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
                            'Week Ending ${review.weekEndDate}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${review.grindScoreChange} grind points earned',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary(context),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable Content
            if (_expanded) ...[
              Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Metrics
                    Text(
                      'Performance Metrics',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _MetricTile(
                          label: 'Applications',
                          value: '${review.applicationsSent}',
                          icon: Icons.send_rounded,
                          color: AppTheme.primary,
                        ),
                        _MetricTile(
                          label: 'Interviews',
                          value: '${review.interviewsReceived}',
                          icon: Icons.forum_rounded,
                          color: AppTheme.warning,
                        ),
                        _MetricTile(
                          label: 'Study Hours',
                          value: '${review.skillHoursCompleted.toStringAsFixed(1)}h',
                          icon: Icons.bolt_rounded,
                          color: AppTheme.success,
                        ),
                        _MetricTile(
                          label: 'Habit Rate',
                          value: '${(review.habitCompletionRate * 100).toStringAsFixed(0)}%',
                          icon: Icons.check_circle_rounded,
                          color: AppTheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Strengths & Weaknesses
                    if (review.strengths.isNotEmpty) ...[
                      const Text(
                        'Strengths & Highlights',
                        style: TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...review.strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_upward_rounded, color: AppTheme.success, size: 16),
                            const SizedBox(width: 12),
                            Expanded(child: Text(s, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                    ],

                    if (review.weaknesses.isNotEmpty) ...[
                      const Text(
                        'Areas to Focus / Weaknesses',
                        style: TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...review.weaknesses.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_downward_rounded, color: AppTheme.accent, size: 16),
                            const SizedBox(width: 12),
                            Expanded(child: Text(w, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],

                    // Reflection Notes
                    if (review.reflectionNotes.isNotEmpty) ...[
                      Text(
                        'Personal Reflection Notes',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDarkAlt : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, width: 1),
                        ),
                        child: Text(
                          review.reflectionNotes,
                          style: TextStyle(
                            color: AppTheme.textSecondary(context),
                            fontSize: 13,
                            height: 1.5,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDarkAlt : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
