import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/habit_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/weekly_review_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Obx(() => CustomScrollView(
          slivers: [
            // ── Top bar with name and greeting ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Niran 🔥',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ctrl.employmentStatus == 'Employed Mode'
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ctrl.employmentStatus,
                        style: TextStyle(
                          color: ctrl.employmentStatus == 'Employed Mode'
                              ? AppTheme.success
                              : AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Weekly Review Alert Banner ───────────────────────────────
            if (ctrl.isWeeklyReviewDue)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _WeeklyReviewBanner(ctrl: ctrl),
                ),
              ),

            // ── 1. Unemployment Counter ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _UnemploymentCounter(ctrl: ctrl),
              ),
            ),

            // ── 2. Today's Targets ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _CareerTargetsWidget(ctrl: ctrl),
              ),
            ),

            // ── 3. Progress Overview ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _ProgressOverviewGrid(ctrl: ctrl),
              ),
            ),

            // ── 4. Active Applications ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Applications Preview',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ctrl.activeApplications == 0
                        ? _EmptyState(
                            message: 'No active applications. Go apply bro!',
                            icon: Icons.send_outlined,
                          )
                        : _ActiveJobsPreview(ctrl: ctrl),
                  ],
                ),
              ),
            ),

            // ── 5. No-Zero-Day Streak ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _NoZeroDayStreakWidget(ctrl: ctrl),
              ),
            ),

            // ── 6. Habit Checklist ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: SectionHeader(
                  title: "Today's habits",
                  action: "Add",
                  onAction: () => _showAddHabitSheet(context, ctrl),
                ),
              ),
            ),

            if (ctrl.habits.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EmptyState(
                    message: 'No habits yet. Add your first one!',
                    icon: Icons.add_task,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: HabitTile(
                      habit: ctrl.habits[i],
                      onToggle: () => ctrl.toggleHabit(ctrl.habits[i]),
                      onDelete: () => ctrl.deleteHabit(ctrl.habits[i]),
                    ),
                  ),
                  childCount: ctrl.habits.length,
                ),
              ),

            // ── 7. Skill Progress ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: _SkillProgressOverview(ctrl: ctrl),
              ),
            ),
          ],
        )),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showAddHabitSheet(BuildContext context, HabitController ctrl) {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '✅';
    String selectedCategory = 'general';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add habit',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. Apply for 2 jobs',
                prefixIcon: Icon(Icons.edit_outlined,
                    color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['✅', '💻', '📨', '🧠', '☀️', '📵', '🏃', '📚', '🎯']
                  .map((e) => GestureDetector(
                        onTap: () => selectedEmoji = e,
                        child: Text(e,
                            style: const TextStyle(fontSize: 28)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    ctrl.addHabit(
                        nameCtrl.text.trim(), selectedEmoji, selectedCategory);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Unemployment Counter Widget ──────────────────────────────────────────────

class _UnemploymentCounter extends StatelessWidget {
  final HabitController ctrl;
  const _UnemploymentCounter({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final status = ctrl.employmentStatus;
    final days = ctrl.daysInStatus;

    Color statusColor;
    String statusTitle;
    String statusDesc;
    IconData icon;
    LinearGradient bgGradient;

    if (status == 'Employed Mode') {
      statusColor = AppTheme.success;
      statusTitle = 'Employed Mode';
      statusDesc = 'Offer Accepted! Let\'s go! 🎉';
      icon = Icons.emoji_events;
      bgGradient = LinearGradient(
        colors: [AppTheme.success.withOpacity(0.3), AppTheme.bgCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (status == 'Internship Mode') {
      statusColor = AppTheme.secondary;
      statusTitle = 'Internship Mode';
      statusDesc = '$days days until internship ends (June 22)';
      icon = Icons.badge_outlined;
      bgGradient = LinearGradient(
        colors: [AppTheme.secondary.withOpacity(0.2), AppTheme.bgCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      statusColor = AppTheme.accent;
      statusTitle = 'Job Hunt Mode';
      statusDesc = '$days days since internship ended';
      icon = Icons.explore_outlined;
      bgGradient = LinearGradient(
        colors: [AppTheme.accent.withOpacity(0.25), AppTheme.bgCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Day $days',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  statusDesc,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
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

// ── Target Progress Widget ───────────────────────────────────────────────────

class _CareerTargetsWidget extends StatelessWidget {
  final HabitController ctrl;
  const _CareerTargetsWidget({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final apps = ctrl.weeklyJobsApplied;
    final hours = ctrl.weeklySkillHours;
    final coding = ctrl.weeklyCodingSessions;
    final dsa = ctrl.weeklyDsaSessions;

    final targetApps = ctrl.targetJobs.value;
    final targetHours = ctrl.targetHours.value;
    final targetCoding = ctrl.targetCoding.value;
    final targetDsa = ctrl.targetDsa.value;

    final paceStatus = ctrl.targetPaceStatus;
    final isBehind = paceStatus == 'Behind';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBehind ? AppTheme.accent.withOpacity(0.3) : AppTheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Targets Pace',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBehind ? AppTheme.accent.withOpacity(0.15) : AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBehind ? '⚠️ Behind pace' : '👍 On track',
                  style: TextStyle(
                    color: isBehind ? AppTheme.accent : AppTheme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (isBehind) ...[
            const SizedBox(height: 8),
            const Text(
              'Warning: You are falling behind this week\'s career targets. Step up the activity today!',
              style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 16),
          _ProgressBarRow(
            label: '📨 Job apps',
            value: apps.toDouble(),
            target: targetApps.toDouble(),
            color: AppTheme.primary,
          ),
          const SizedBox(height: 12),
          _ProgressBarRow(
            label: '⚡ Study hours',
            value: hours,
            target: targetHours,
            color: AppTheme.warning,
            isHours: true,
          ),
          const SizedBox(height: 12),
          _ProgressBarRow(
            label: '💻 Coding sessions',
            value: coding.toDouble(),
            target: targetCoding.toDouble(),
            color: AppTheme.secondary,
          ),
          const SizedBox(height: 12),
          _ProgressBarRow(
            label: '🧠 DSA sessions',
            value: dsa.toDouble(),
            target: targetDsa.toDouble(),
            color: AppTheme.accent,
          ),
        ],
      ),
    );
  }
}

class _ProgressBarRow extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final Color color;
  final bool isHours;

  const _ProgressBarRow({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    this.isHours = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target == 0.0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    final valueStr = isHours ? '${value.toStringAsFixed(1)}h' : '${value.toInt()}';
    final targetStr = isHours ? '${target.toStringAsFixed(0)}h' : '${target.toInt()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            Text(
              '$valueStr / $targetStr (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppTheme.bgCardLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Progress Overview Grid Widget ────────────────────────────────────────────

class _ProgressOverviewGrid extends StatelessWidget {
  final HabitController ctrl;
  const _ProgressOverviewGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outcome Metrics',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _MiniStatCard(
              label: 'Jobs applied this week',
              value: '${ctrl.weeklyJobsApplied}',
              icon: Icons.send_outlined,
              color: AppTheme.primary,
            ),
            _MiniStatCard(
              label: 'Active applications',
              value: '${ctrl.activeApplications}',
              icon: Icons.work_outline,
              color: AppTheme.secondary,
            ),
            _MiniStatCard(
              label: 'Interviews scheduled',
              value: '${ctrl.totalInterviewsScheduled}',
              icon: Icons.forum_outlined,
              color: AppTheme.warning,
            ),
            _MiniStatCard(
              label: 'Study hours this week',
              value: '${ctrl.weeklySkillHours.toStringAsFixed(1)}h',
              icon: Icons.bolt_outlined,
              color: AppTheme.success,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary.withOpacity(0.3), AppTheme.secondary.withOpacity(0.15)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.warning, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grind Score',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ctrl.grindRank,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${ctrl.grindScore} pts',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgCardLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── No-Zero-Day Streak Widget ────────────────────────────────────────────────

class _NoZeroDayStreakWidget extends StatelessWidget {
  final HabitController ctrl;
  const _NoZeroDayStreakWidget({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final streak = ctrl.noZeroDayStreak;
    final todaySuccessful = ctrl.checkActivityForDay(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: todaySuccessful ? AppTheme.success.withOpacity(0.3) : AppTheme.textSecondary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (todaySuccessful ? AppTheme.success : AppTheme.warning).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                todaySuccessful ? '✅' : '🔥',
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No-Zero-Day Streak: $streak days',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todaySuccessful
                      ? 'Today is successful! No Zero Days! 🎉'
                      : 'Zero Day Pending: Log an application, 30m study, or coding/DSA habit to make today count!',
                  style: TextStyle(
                    color: todaySuccessful ? AppTheme.success : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

// ── Active Jobs Preview Widget ───────────────────────────────────────────────

class _ActiveJobsPreview extends StatelessWidget {
  final HabitController ctrl;
  const _ActiveJobsPreview({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final active = ctrl.jobs
        .where((j) => j.status == 'applied' || j.status == 'interview')
        .take(3)
        .toList();

    return Column(
      children: active.map((job) {
        final isInterview = job.status == 'interview';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isInterview
                  ? AppTheme.warning.withOpacity(0.4)
                  : AppTheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    job.company[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.company,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(job.role,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isInterview
                      ? AppTheme.warning.withOpacity(0.15)
                      : AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isInterview ? '🎯 Interview' : '📨 Applied',
                  style: TextStyle(
                    color: isInterview ? AppTheme.warning : AppTheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Skill Progress Widget ────────────────────────────────────────────────────

class _SkillProgressOverview extends StatelessWidget {
  final HabitController ctrl;
  const _SkillProgressOverview({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> skillTotals = {};
    for (final log in ctrl.skillLogs) {
      skillTotals[log.skill] = (skillTotals[log.skill] ?? 0) + log.hoursStudied;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Skill Study Progress',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bgCardLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total logged study this week', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  Text(
                    '${ctrl.weeklySkillHours.toStringAsFixed(1)} hrs',
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (skillTotals.isEmpty) ...[
                const SizedBox(height: 12),
                const Text('No study sessions logged yet. Head to the Skill tab to log hours.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ] else ...[
                const SizedBox(height: 16),
                ...skillTotals.entries.take(3).map((e) {
                  final maxVal = skillTotals.values.fold(0.0, (a, b) => a > b ? a : b);
                  final pct = maxVal == 0.0 ? 0.0 : e.value / maxVal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('${e.value.toStringAsFixed(1)} hrs', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 4,
                            backgroundColor: AppTheme.bgCardLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Weekly Review Banner Widget ──────────────────────────────────────────────

class _WeeklyReviewBanner extends StatelessWidget {
  final HabitController ctrl;
  const _WeeklyReviewBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Career Review Due!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Evaluate your progress for the week ending ${ctrl.lastSundayKey}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const WeeklyReviewDialog(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
            child: const Text('Start Review'),
          ),
        ],
      ),
    );
  }
}

// ── Empty State Widget ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.textSecondary.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium),
        ],
      ),
    );
  }
}

