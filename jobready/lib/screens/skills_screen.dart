import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/habit_controller.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';

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
      backgroundColor: AppTheme.bgDark,
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

        // Build per-skill summary
        final Map<String, double> skillTotals = {};
        for (final log in logs) {
          skillTotals[log.skill] =
              (skillTotals[log.skill] ?? 0) + log.hoursStudied;
        }

        // Last 7 days bar chart data
        final weekData = _buildWeekData(logs);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Weekly hours card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('This week',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '${ctrl.totalSkillHoursThisWeek.toStringAsFixed(1)} hrs',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
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
                                leftTitles: AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                topTitles: AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      const days = [
                                        'M', 'T', 'W', 'T', 'F', 'S', 'S'
                                      ];
                                      return Text(
                                        days[v.toInt() % 7],
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: weekData,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Skill totals
            if (skillTotals.isNotEmpty) ...[
              SectionHeader(
                title: 'All time',
                action: 'Log session',
                onAction: () => _showLogSkillSheet(context, ctrl),
              ),
              const SizedBox(height: 12),
              ...skillTotals.entries.map((e) => _SkillRow(
                    skill: e.key,
                    hours: e.value,
                    maxHours: skillTotals.values
                        .fold(0.0, (a, b) => a > b ? a : b),
                  )),
            ] else ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.bolt_outlined,
                        color: AppTheme.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text('No skill logs yet',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('Log your first study session',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showLogSkillSheet(context, ctrl),
                      icon: const Icon(Icons.add),
                      label: const Text('Log session'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }

  List<BarChartGroupData> _buildWeekData(List<SkillLogModel> logs) {
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
            color: total > 0 ? AppTheme.primary : AppTheme.bgCardLight,
            width: 18,
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

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log skill session',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // Skill chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedSkills
                    .map((s) => GestureDetector(
                          onTap: () => setState(() => selectedSkill = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selectedSkill == s
                                  ? AppTheme.primary
                                  : AppTheme.bgCardLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedSkill == s
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary
                                        .withOpacity(0.2),
                              ),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                  color: selectedSkill == s
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // Hours slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hours studied',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '${hours.toStringAsFixed(1)} hrs',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Slider(
                value: hours,
                min: 0.5,
                max: 8.0,
                divisions: 15,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.bgCardLight,
                onChanged: (v) => setState(() => hours = v),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: notesCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Notes (optional) — what did you learn?',
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ctrl.logSkill(selectedSkill, hours,
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: const Text('Log session'),
                ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppTheme.bgCardLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
