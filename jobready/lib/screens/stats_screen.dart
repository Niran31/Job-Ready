import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/habit_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../widgets/section_header.dart';
import '../widgets/glass_card.dart';
import 'weekly_review_history_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Stats & Trends'),
      ),
      body: Obx(() {
        // Trigger Obx observation
        final _ = [ctrl.habits.length, ctrl.jobs.length, ctrl.skillLogs.length];

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Grind Score Card & Breakdown ──────────────────────────────
            _GrindScoreDetailsCard(ctrl: ctrl),
            const SizedBox(height: 20),

            // ── Weekly Review History Nav Card ────────────────────────────
            const _WeeklyReviewHistoryNavCard(),
            const SizedBox(height: 32),

            // ── Interview Conversion ──────────────────────────────────────
            _InterviewConversionCard(ctrl: ctrl),
            const SizedBox(height: 32),

            // ── Future Projections ────────────────────────────────────────
            _FutureProjectionWidget(ctrl: ctrl),
            const SizedBox(height: 32),

            // ── Grind Score 7-Day History Chart ───────────────────────────
            _ChartSectionCard(
              title: 'Grind Score Progression (7 Days)',
              chart: _GrindScoreLineChart(ctrl: ctrl),
            ),
            const SizedBox(height: 24),

            // ── Applications 4-Week Bar Chart ─────────────────────────────
            _ChartSectionCard(
              title: 'Applications Per Week',
              chart: _AppsPerWeekBarChart(ctrl: ctrl),
            ),
            const SizedBox(height: 24),

            // ── Skill Hours 7-Day Line Chart ──────────────────────────────
            _ChartSectionCard(
              title: 'Skill Study Hours Trend (7 Days)',
              chart: _SkillHoursLineChart(ctrl: ctrl),
            ),
            const SizedBox(height: 24),

            // ── Habit Completion 7-Day Trend Chart ────────────────────────
            _ChartSectionCard(
              title: 'Habit Completion Consistency (7 Days)',
              chart: _HabitsCompletionLineChart(ctrl: ctrl),
            ),
            const SizedBox(height: 32),

            // ── Job Funnel ────────────────────────────────────────────────
            SectionHeader(title: 'Job pipeline funnel'),
            const SizedBox(height: 16),
            _JobFunnelWidget(ctrl: ctrl),

            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }
}

// ── Grid Stats & Details Card ────────────────────────────────────────────────

class _GrindScoreDetailsCard extends StatefulWidget {
  final HabitController ctrl;
  const _GrindScoreDetailsCard({required this.ctrl});

  @override
  State<_GrindScoreDetailsCard> createState() => _GrindScoreDetailsCardState();
}

class _GrindScoreDetailsCardState extends State<_GrindScoreDetailsCard> {
  bool _expanded = false;

  int get _nextMilestoneScore {
    final s = widget.ctrl.grindScore;
    if (s <= 100) return 101;
    if (s <= 300) return 301;
    if (s <= 600) return 601;
    if (s <= 1000) return 1001;
    return 2000;
  }

  String get _nextMilestoneRank {
    final s = widget.ctrl.grindScore;
    if (s <= 100) return 'Momentum';
    if (s <= 300) return 'Builder';
    if (s <= 600) return 'Grinder';
    if (s <= 1000) return 'Career Beast';
    return 'Endless Beast';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.ctrl.grindScore;
    final rank = widget.ctrl.grindRank;
    final nextS = _nextMilestoneScore;
    final nextR = _nextMilestoneRank;
    final pct = (s / nextS).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate score details breakdown
    int appPts = 0;
    int interviewPts = 0;
    int offerPts = 0;
    for (final j in widget.ctrl.jobs) {
      if (j.status == 'interview') {
        appPts += 5;
        interviewPts += 25;
      } else if (j.status == 'offer') {
        appPts += 5;
        offerPts += 100;
      } else {
        appPts += 5;
      }
    }

    int studyPts = 0;
    int dsaPts = 0;
    int projectPts = 0;
    for (final sLog in widget.ctrl.skillLogs) {
      studyPts += (sLog.hoursStudied * 2).toInt();
      if (sLog.skill == 'DSA') {
        dsaPts += 5;
      }
      if (['flutter', 'dart', 'react', 'python', 'system design', 'fastapi', 'flask', 'sql', 'ml / ai']
          .contains(sLog.skill.toLowerCase())) {
        projectPts += 10;
      }
    }

    int habitPts = 0;
    for (final h in widget.ctrl.habits) {
      final nameLower = h.name.toLowerCase();
      final isDsa = nameLower.contains('dsa') || nameLower.contains('leetcode');
      final isProject = nameLower.contains('code') || nameLower.contains('build');
      for (final _ in h.completedDates) {
        habitPts += 1;
        if (isDsa) dsaPts += 5;
        if (isProject) projectPts += 10;
      }
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      gradient: AppGradients.welcomeCard(context),
      borderColor: AppTheme.primary.withOpacity(0.3),
      isImportant: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Grind Score',
                        style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$s pts',
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rank,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureButton(
                  icon: _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),

          // Milestone Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Next Milestone: $nextR', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
                    Text('$s / $nextS pts', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),

          if (_expanded) ...[
            Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDarkAlt.withOpacity(0.5) : AppTheme.surfaceLight.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _BreakdownLine(label: '📨 Job applications (+5)', value: appPts),
                  _BreakdownLine(label: '🎯 Interview invites (+25)', value: interviewPts),
                  _BreakdownLine(label: '🎉 Offers secured (+100)', value: offerPts),
                  _BreakdownLine(label: '⚡ Study hours logged (+2/hr)', value: studyPts),
                  _BreakdownLine(label: '🧠 DSA sessions completed (+5)', value: dsaPts),
                  _BreakdownLine(label: '💻 Project coding sessions (+10)', value: projectPts),
                  _BreakdownLine(label: '✅ General habits completed (+1)', value: habitPts),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GestureButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const GestureButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.textSecondary(context).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.textPrimary(context), size: 24),
      ),
    );
  }
}

class _BreakdownLine extends StatelessWidget {
  final String label;
  final int value;
  const _BreakdownLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.w500)),
          Text(
            '+$value pts',
            style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Review History Navigation Card ─────────────────────────────────────

class _WeeklyReviewHistoryNavCard extends StatelessWidget {
  const _WeeklyReviewHistoryNavCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => const WeeklyReviewHistoryScreen()),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_edu, color: AppTheme.primary, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Reviews History',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Browse your past reflections & weekly grades',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Interview Conversion ─────────────────────────────────────────────────────

class _InterviewConversionCard extends StatelessWidget {
  final HabitController ctrl;
  const _InterviewConversionCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final conversion = ctrl.interviewConversionRate;
    final total = ctrl.totalJobsApplied;
    final interviews = ctrl.totalInterviewsScheduled;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppTheme.warning.withOpacity(0.25),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: total == 0 ? 0.0 : (interviews / total),
                  strokeWidth: 10,
                  backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  color: AppTheme.warning,
                ),
                Text(
                  '${conversion.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interview Conversion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$interviews stage advancement from $total total job application submissions.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Future Projections Widget ────────────────────────────────────────────────

class _FutureProjectionWidget extends StatelessWidget {
  final HabitController ctrl;
  const _FutureProjectionWidget({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final appPace = ctrl.monthlyAppPace;
    final skillPace = ctrl.monthlySkillPace;
    final interviewsPace = ctrl.expectedInterviewsPerMonth;
    final status = ctrl.targetPaceStatus;

    Color statusColor;
    if (status == 'Ahead') {
      statusColor = AppTheme.success;
    } else if (status == 'Behind') {
      statusColor = AppTheme.error;
    } else {
      statusColor = AppTheme.primary;
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: statusColor.withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Future Month Projection',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Estimated monthly output based on your activity pace over the last 30 days:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _ProjectionLine(
            icon: Icons.send_outlined,
            label: 'Job Applications / month',
            value: '${appPace.toStringAsFixed(0)} apps',
            color: AppTheme.primary,
          ),
          _ProjectionLine(
            icon: Icons.bolt_outlined,
            label: 'Skill Study Hours / month',
            value: '${skillPace.toStringAsFixed(0)} hrs',
            color: AppTheme.success,
          ),
          _ProjectionLine(
            icon: Icons.forum_outlined,
            label: 'Expected Interviews / month',
            value: '${interviewsPace.toStringAsFixed(1)} calls',
            color: AppTheme.warning,
          ),
        ],
      ),
    );
  }
}

class _ProjectionLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProjectionLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Chart Cards ──────────────────────────────────────────────────────────────

class _ChartSectionCard extends StatelessWidget {
  final String title;
  final Widget chart;

  const _ChartSectionCard({required this.title, required this.chart});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: chart,
          ),
        ],
      ),
    );
  }
}

// ── Fl Chart Visualizations ──────────────────────────────────────────────────

class _GrindScoreLineChart extends StatelessWidget {
  final HabitController ctrl;
  const _GrindScoreLineChart({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final score = ctrl.getGrindScoreOnDate(day);
      spots.add(FlSpot((6 - i).toDouble(), score.toDouble()));
    }

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b) + 20;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _buildWeekTitles(context),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primary.withOpacity(0.15),
            ),
          ),
        ],
        maxY: maxY,
      ),
    );
  }
}

class _AppsPerWeekBarChart extends StatelessWidget {
  final HabitController ctrl;
  const _AppsPerWeekBarChart({required this.ctrl});

  List<int> _getApps() {
    final now = DateTime.now();
    final list = <int>[];
    for (int i = 3; i >= 0; i--) {
      final start = ctrl.startOfWeek().subtract(Duration(days: i * 7));
      final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
      final count = ctrl.jobs.where((j) {
        final date = DateTime.tryParse(j.appliedDate);
        if (date == null) return false;
        return !date.isBefore(start) && !date.isAfter(end);
      }).length;
      list.add(count);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getApps();
    final maxY = weeklyData.fold(0, (a, b) => a > b ? a : b).toDouble() + 2;

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx > 3) return const SizedBox.shrink();
                final labels = ['W-3', 'W-2', 'W-1', 'This W'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(labels[idx], style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
        ),
        barGroups: weeklyData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: AppTheme.secondary,
                width: 24,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SkillHoursLineChart extends StatelessWidget {
  final HabitController ctrl;
  const _SkillHoursLineChart({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final hours = ctrl.skillLogs
          .where((s) => s.date == key)
          .fold(0.0, (sum, s) => sum + s.hoursStudied);
      spots.add(FlSpot((6 - i).toDouble(), hours));
    }

    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b) + 1.5;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _buildWeekTitles(context),
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.success,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.success.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}

class _HabitsCompletionLineChart extends StatelessWidget {
  final HabitController ctrl;
  const _HabitsCompletionLineChart({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final completed = ctrl.habits.where((h) => h.completedDates.contains(key)).length;
      final total = ctrl.habits.length;
      final pct = total == 0 ? 0.0 : (completed / total) * 100;
      spots.add(FlSpot((6 - i).toDouble(), pct));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _buildWeekTitles(context, isPercentage: true),
        maxY: 110,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.accent,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.accent.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}

// ── Chart Helper ─────────────────────────────────────────────────────────────

FlTitlesData _buildWeekTitles(BuildContext context, {bool isPercentage = false}) {
  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: isPercentage,
        reservedSize: 36,
        getTitlesWidget: (v, _) {
          if (v == 0 || v == 50 || v == 100) {
            return Text('${v.toInt()}%', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w600));
          }
          return const SizedBox.shrink();
        },
      ),
    ),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (v, _) {
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final index = v.toInt();
          if (index < 0 || index > 6) return const SizedBox.shrink();

          // Calculate current day index relative to today
          final now = DateTime.now();
          final day = now.subtract(Duration(days: 6 - index));
          final label = days[day.weekday - 1];

          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(label, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w600)),
          );
        },
      ),
    ),
  );
}

// ── Job Funnel Widget ────────────────────────────────────────────────────────

class _JobFunnelWidget extends StatelessWidget {
  final HabitController ctrl;
  const _JobFunnelWidget({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('Applied 📨', 'applied', AppTheme.primary),
      ('Interviews 🎯', 'interview', AppTheme.warning),
      ('Offers 🎉', 'offer', AppTheme.success),
      ('Rejected ❌', 'rejected', AppTheme.error),
      ('Ghosted 👻', 'ghosted', AppTheme.textMuted),
    ];
    final total = ctrl.jobs.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: stages.map((s) {
          final count = ctrl.jobs.where((j) => j.status == s.$2).length;
          final pct = total == 0 ? 0.0 : count / total;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.$1, style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('$count ($total total)', style: TextStyle(color: s.$3, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    valueColor: AlwaysStoppedAnimation<Color>(s.$3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
