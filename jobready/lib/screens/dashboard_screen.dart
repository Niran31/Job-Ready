import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/habit_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/habit_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/weekly_review_dialog.dart';
import '../widgets/saas_card.dart';
import '../widgets/saas_button.dart';
import '../services/sync_service.dart';
import 'resume_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ctrl.checkGitHubCommits();
            if (Get.isRegistered<SyncService>()) {
              final syncService = SyncService.to;
              if (syncService.isLoggedIn) {
                await syncService.syncAll(syncService.currentUser.value!.uid);
              }
            }
          },
          backgroundColor: AppTheme.cardColor(context),
          color: AppTheme.primary,
          child: Obx(() => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // ── Top bar with name and greeting ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                          '${SyncService.to.currentUser.value?.displayName?.split(' ').first ?? 'User'} 🔥',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ctrl.employmentStatus == 'Employed Mode'
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        ctrl.employmentStatus,
                        style: TextStyle(
                          color: ctrl.employmentStatus == 'Employed Mode'
                              ? AppTheme.success
                              : AppTheme.primary,
                          fontSize: 13,
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _WeeklyReviewBanner(ctrl: ctrl),
                ),
              ),

            // ── 1. Unemployment Counter ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _UnemploymentCounter(ctrl: ctrl),
              ),
            ),

            // ── 2. Today's Targets ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _CareerTargetsWidget(ctrl: ctrl),
              ),
            ),

            // ── Resume Analyzer Card ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _ResumeAnalyzerCard(),
              ),
            ),

            // ── 3. Progress Overview ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _ProgressOverviewGrid(ctrl: ctrl),
              ),
            ),

            // ── 4. Active Applications ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Active Applications Preview'),
                    const SizedBox(height: 12),
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _NoZeroDayStreakWidget(ctrl: ctrl),
              ),
            ),

            // ── 6. Habit Checklist ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: SectionHeader(
                  title: "Today's habits",
                  action: "+ Add",
                  onAction: () => _showAddHabitSheet(context, ctrl),
                ),
              ),
            ),

            if (ctrl.habits.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: HabitTile(
                      habit: ctrl.habits[i],
                      onToggle: () {
                        final wasDone = ctrl.habits[i].isCompletedToday();
                        ctrl.toggleHabit(ctrl.habits[i]);
                        if (!wasDone) {
                          _showCelebrationOverlay(context);
                        }
                      },
                      onDelete: () => ctrl.deleteHabit(ctrl.habits[i]),
                    ),
                  ),
                  childCount: ctrl.habits.length,
                ),
              ),

            // ── 7. Skill Progress ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                child: _SkillProgressOverview(ctrl: ctrl),
              ),
            ),
          ],
        ))),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showCelebrationOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: Center(
            child: Lottie.asset(
              'assets/lottie/confetti.json',
              repeat: false,
              fit: BoxFit.contain,
              width: 300,
              height: 300,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  void _showAddHabitSheet(BuildContext context, HabitController ctrl) {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '✅';
    String selectedCategory = 'general';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add habit',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(color: AppTheme.textPrimary(context)),
              decoration: InputDecoration(
                hintText: 'e.g. Apply for 2 jobs',
                prefixIcon: Icon(Icons.edit_outlined,
                    color: AppTheme.textSecondary(context)),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['✅', '💻', '📨', '🧠', '☀️', '📵', '🏃', '📚', '🎯']
                  .map((e) => StatefulBuilder(
                    builder: (ctx, setState) => GestureDetector(
                          onTap: () {
                            selectedEmoji = e;
                            (ctx as Element).markNeedsBuild();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedEmoji == e 
                                  ? AppTheme.primary.withOpacity(0.15) 
                                  : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedEmoji == e 
                                    ? AppTheme.primary 
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                  ))
                  .toList(),
            ),
            const SizedBox(height: 32),
            SaasButton(
              text: 'Add habit',
              width: double.infinity,
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  ctrl.addHabit(
                      nameCtrl.text.trim(), selectedEmoji, selectedCategory);
                  Navigator.pop(ctx);
                }
              },
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

    if (status == 'Employed Mode') {
      statusColor = AppTheme.success;
      statusTitle = 'Employed Mode';
      statusDesc = 'Offer Accepted! Let\'s go! 🎉';
      icon = Icons.emoji_events;
    } else if (status == 'Internship Mode') {
      statusColor = AppTheme.secondary;
      statusTitle = 'Internship Mode';
      statusDesc = '$days days until internship ends (June 22)';
      icon = Icons.badge_outlined;
    } else {
      statusColor = AppTheme.accent;
      statusTitle = 'Job Hunt Mode';
      statusDesc = '$days days since internship ended';
      icon = Icons.explore_outlined;
    }

    return SaasCard(
      padding: const EdgeInsets.all(20),
      borderColor: statusColor.withOpacity(0.3),
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
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
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

    return SaasCard(
      borderColor: isBehind 
          ? AppTheme.accent.withOpacity(0.3) 
          : AppTheme.primary.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Targets Pace',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBehind ? AppTheme.accent.withOpacity(0.15) : AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Warning: You are falling behind this week\'s career targets. Step up the activity today!',
                      style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _ProgressBarRow(
            label: '📨 Job apps',
            value: apps.toDouble(),
            target: targetApps.toDouble(),
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          _ProgressBarRow(
            label: '⚡ Study hours',
            value: hours,
            target: targetHours,
            color: AppTheme.warning,
            isHours: true,
          ),
          const SizedBox(height: 16),
          _ProgressBarRow(
            label: '💻 Coding sessions',
            value: coding.toDouble(),
            target: targetCoding.toDouble(),
            color: AppTheme.secondary,
          ),
          const SizedBox(height: 16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.w600)),
            Text(
              '$valueStr / $targetStr (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Resume Analyzer Card Widget ──────────────────────────────────────────────

class _ResumeAnalyzerCard extends StatelessWidget {
  const _ResumeAnalyzerCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ResumeScreen()),
      child: SaasCard(
        padding: const EdgeInsets.all(20),
        borderColor: Colors.indigo.withOpacity(0.3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined, color: Colors.indigo, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resume Analyzer',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check ATS score & keyword gaps',
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.indigo, size: 16),
          ],
        ),
      ),
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
        SectionHeader(title: 'Outcome Metrics'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            StatCard(
              label: 'Jobs applied this week',
              value: '${ctrl.weeklyJobsApplied}',
              icon: Icons.send_outlined,
              color: AppTheme.primary,
            ),
            StatCard(
              label: 'Active applications',
              value: '${ctrl.activeApplications}',
              icon: Icons.work_outline,
              color: AppTheme.secondary,
            ),
            StatCard(
              label: 'Interviews scheduled',
              value: '${ctrl.totalInterviewsScheduled}',
              icon: Icons.forum_outlined,
              color: AppTheme.warning,
            ),
            StatCard(
              label: 'Study hours this week',
              value: '${ctrl.weeklySkillHours.toStringAsFixed(1)}h',
              icon: Icons.bolt_outlined,
              color: AppTheme.success,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SaasCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderColor: AppTheme.primary.withOpacity(0.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: AppTheme.warning, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grind Score',
                        style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ctrl.grindRank,
                        style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${ctrl.grindScore} pts',
                style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
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

    return SaasCard(
      padding: const EdgeInsets.all(20),
      borderColor: todaySuccessful ? AppTheme.success.withOpacity(0.3) : AppTheme.textSecondary(context).withOpacity(0.15),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (todaySuccessful ? AppTheme.success : AppTheme.warning).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                todaySuccessful ? '✅' : '🔥',
                style: const TextStyle(fontSize: 28),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No-Zero-Day Streak: $streak days',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  todaySuccessful
                      ? 'Today is successful! No Zero Days! 🎉'
                      : 'Zero Day Pending: Log an application, 30m study, or coding/DSA habit to make today count!',
                  style: TextStyle(
                    color: todaySuccessful ? AppTheme.success : AppTheme.textSecondary(context),
                    fontSize: 13,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: active.map((job) {
        final isInterview = job.status == 'interview';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isInterview
                  ? AppTheme.warning.withOpacity(0.4)
                  : AppTheme.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    job.company[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.company,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(job.role,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isInterview
                      ? AppTheme.warning.withOpacity(0.15)
                      : AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isInterview ? '🎯 Interview' : '📨 Applied',
                  style: TextStyle(
                    color: isInterview ? AppTheme.warning : AppTheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
        SectionHeader(title: 'Weekly Skill Study Progress'),
        const SizedBox(height: 12),
        SaasCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total logged study this week', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(
                    '${ctrl.weeklySkillHours.toStringAsFixed(1)} hrs',
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (skillTotals.isEmpty) ...[
                const SizedBox(height: 16),
                Text('No study sessions logged yet. Head to the Skill tab to log hours.',
                    style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
              ] else ...[
                const SizedBox(height: 20),
                ...skillTotals.entries.take(3).map((e) {
                  final maxVal = skillTotals.values.fold(0.0, (a, b) => a > b ? a : b);
                  final pct = maxVal == 0.0 ? 0.0 : e.value / maxVal;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('${e.value.toStringAsFixed(1)} hrs', style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('📅', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Career Review Due!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Evaluate your progress for the week ending ${ctrl.lastSundayKey}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Review', style: TextStyle(fontWeight: FontWeight.w800)),
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
    return SaasCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
