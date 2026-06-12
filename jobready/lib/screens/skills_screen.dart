import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/habit_controller.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  static const _suggestedSkills = [
    'Flutter', 'Dart', 'Python', 'FastAPI', 'Flask',
    'React', 'DSA', 'ML / AI', 'SQL', 'System Design',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showLogSkillSheet(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        final logs = ctrl.skillLogs;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Build per-skill summary
        final Map<String, double> skillTotals = {};
        for (final log in logs) {
          skillTotals[log.skill] =
              (skillTotals[log.skill] ?? 0) + log.hoursStudied;
        }

        // Last 7 days bar chart data
        final weekData = _buildWeekData(logs, isDark);

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Weekly hours card
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderColor: AppTheme.primary.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('This week',
                          style: Theme.of(context).textTheme.titleLarge),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${ctrl.totalSkillHoursThisWeek.toStringAsFixed(1)} hrs',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 140,
                    child: weekData.isEmpty
                        ? Center(
                            child: Text('Log your first session!',
                                style:
                                    Theme.of(context).textTheme.bodyMedium))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: weekData
                                      .map((d) => d.barRods.isEmpty ? 0.0 : d.barRods.first.toY)
                                      .fold(0.0, (a, b) => a > b ? a : b) +
                                  1,
                              barTouchData:
                                  BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      const days = [
                                        'M', 'T', 'W', 'T', 'F', 'S', 'S'
                                      ];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          days[v.toInt() % 7],
                                          style: TextStyle(
                                              color: AppTheme.textSecondary(context),
                                              fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: weekData,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Skill totals
            if (skillTotals.isNotEmpty) ...[
              SectionHeader(
                title: 'All time',
                action: '+ Log session',
                onAction: () => _showLogSkillSheet(context, ctrl),
              ),
              const SizedBox(height: 16),
              ...skillTotals.entries.map((e) => _SkillRow(
                    skill: e.key,
                    hours: e.value,
                    maxHours: skillTotals.values
                        .fold(0.0, (a, b) => a > b ? a : b),
                  )),
            ] else ...[
              const SizedBox(height: 40),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_outlined, color: AppTheme.primary, size: 48),
                      ),
                      const SizedBox(height: 24),
                      Text('No skill logs yet',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Log your first study session',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 32),
                      GradientButton(
                        text: 'Log session',
                        icon: Icons.add,
                        onPressed: () => _showLogSkillSheet(context, ctrl),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }

  List<BarChartGroupData> _buildWeekData(List<SkillLogModel> logs, bool isDark) {
    final now = DateTime.now();
    final List<BarChartGroupData> result = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final total = logs
          .where((l) => l.date == key)
          .fold(0.0, (sum, l) => sum + l.hoursStudied);

      result.add(BarChartGroupData(
        x: 6 - i,
        barRods: [
          BarChartRodData(
            toY: total,
            color: total > 0 ? AppTheme.primary : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ));
    }
    return result;
  }

  void _showLogSkillSheet(BuildContext context, HabitController ctrl) {
    String selectedSkill = _suggestedSkills[0];
    double hours = 1.0;
    final notesCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log skill session',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),

              // Skill chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _suggestedSkills
                    .map((s) => GestureDetector(
                          onTap: () => setState(() => selectedSkill = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedSkill == s
                                  ? AppTheme.primary
                                  : (isDark ? AppTheme.cardDarkAlt : AppTheme.surfaceLight),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedSkill == s
                                    ? AppTheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                  color: selectedSkill == s
                                      ? Colors.white
                                      : AppTheme.textSecondary(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),

              // Hours slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hours studied',
                      style: Theme.of(context).textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${hours.toStringAsFixed(1)} hrs',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: hours,
                min: 0.5,
                max: 8.0,
                divisions: 15,
                onChanged: (v) => setState(() => hours = v),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: notesCtrl,
                style: TextStyle(color: AppTheme.textPrimary(context)),
                decoration: const InputDecoration(
                  hintText: 'Notes (optional) — what did you learn?',
                ),
              ),
              const SizedBox(height: 32),

              GradientButton(
                text: 'Log session',
                width: double.infinity,
                onPressed: () {
                  ctrl.logSkill(selectedSkill, hours,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim());
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final String skill;
  final double hours;
  final double maxHours;

  const _SkillRow(
      {required this.skill, required this.hours, required this.maxHours});

  @override
  Widget build(BuildContext context) {
    final pct = maxHours == 0 ? 0.0 : hours / maxHours;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${hours.toStringAsFixed(1)} hrs',
                style: const TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
