import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/habit_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/saas_card.dart';
import '../widgets/saas_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    final name = SyncService.to.currentUser.value?.displayName;
    _userName = (name != null && name.isNotEmpty) ? name : 'User';
  }

  Future<void> _savePrefs() async {
    final user = SyncService.to.currentUser.value;
    if (user != null) {
      await user.updateDisplayName(_userName);
      // Force trigger the reactive update in dashboard
      SyncService.to.currentUser.refresh();
    }
  }

  String _formatTime(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile section
          SectionHeader(title: 'Profile'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Your name',
            trailing: Text(_userName,
                style: TextStyle(color: AppTheme.textSecondary(context), fontWeight: FontWeight.bold)),
            onTap: () => _showNameDialog(),
          ),

          const SizedBox(height: 32),

          // Targets section
          SectionHeader(title: '🎯 Weekly career targets'),
          const SizedBox(height: 12),
          _TargetsContainer(ctrl: Get.find<HabitController>()),

          const SizedBox(height: 32),

          // Reminders section
          SectionHeader(title: '🔔 Reminders & Notifications'),
          const SizedBox(height: 12),
          _RemindersSection(ctrl: Get.find<NotificationController>()),

          const SizedBox(height: 40),

          // GitHub tracking section
          SectionHeader(title: '💻 GitHub Commit Tracker'),
          const SizedBox(height: 12),
          _GitHubSettingsCard(ctrl: Get.find<HabitController>()),

          const SizedBox(height: 32),

          // Firebase sync section
          SectionHeader(title: '☁️ Firebase Cloud Sync'),
          const SizedBox(height: 12),
          const _FirebaseSettingsCard(),

          const SizedBox(height: 40),

          // About
          SectionHeader(title: 'About'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App version',
            trailing: Text('1.0.0', style: TextStyle(color: AppTheme.textSecondary(context))),
          ),
          _SettingsTile(
            icon: Icons.code,
            title: 'Built by',
            trailing: const Text('Niran × Velzyn Labs',
                style: TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w800)),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showNameDialog() {
    final ctrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Your name',
            style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: AppTheme.textPrimary(context)),
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary(context)))),
          ElevatedButton(
            onPressed: () {
              setState(() => _userName = ctrl.text.trim());
              _savePrefs();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile(
      {required this.icon,
      required this.title,
      this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return SaasCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: AppTheme.primary, size: 24),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          trailing: trailing,
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}

// ── Targets Widgets ─────────────────────────────────────────────────────────

class _TargetsContainer extends StatelessWidget {
  final HabitController ctrl;
  const _TargetsContainer({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SaasCard(
      padding: EdgeInsets.zero,
      borderColor: AppTheme.primary.withOpacity(0.15),
      child: Obx(() => Column(
        children: [
          _TargetCounterRow(
            label: 'Job applications',
            valueText: '${ctrl.targetJobs.value}',
            onDecrement: () {
              if (ctrl.targetJobs.value > 1) {
                ctrl.updateTargets(jobsVal: ctrl.targetJobs.value - 1);
              }
            },
            onIncrement: () {
              ctrl.updateTargets(jobsVal: ctrl.targetJobs.value + 1);
            },
          ),
          Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),
          _TargetCounterRow(
            label: 'Study hours',
            valueText: '${ctrl.targetHours.value.toStringAsFixed(0)}h',
            onDecrement: () {
              if (ctrl.targetHours.value > 1.0) {
                ctrl.updateTargets(hoursVal: ctrl.targetHours.value - 1.0);
              }
            },
            onIncrement: () {
              ctrl.updateTargets(hoursVal: ctrl.targetHours.value + 1.0);
            },
          ),
          Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),
          _TargetCounterRow(
            label: 'Coding sessions',
            valueText: '${ctrl.targetCoding.value}',
            onDecrement: () {
              if (ctrl.targetCoding.value > 1) {
                ctrl.updateTargets(codingVal: ctrl.targetCoding.value - 1);
              }
            },
            onIncrement: () {
              ctrl.updateTargets(codingVal: ctrl.targetCoding.value + 1);
            },
          ),
          Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),
          _TargetCounterRow(
            label: 'DSA sessions',
            valueText: '${ctrl.targetDsa.value}',
            onDecrement: () {
              if (ctrl.targetDsa.value > 1) {
                ctrl.updateTargets(dsaVal: ctrl.targetDsa.value - 1);
              }
            },
            onIncrement: () {
              ctrl.updateTargets(dsaVal: ctrl.targetDsa.value + 1);
            },
          ),
        ],
      )),
    );
  }
}

class _TargetCounterRow extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _TargetCounterRow({
    required this.label,
    required this.valueText,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.secondary, size: 24),
                onPressed: onDecrement,
              ),
              SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 24),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── GitHub Settings Widget ───────────────────────────────────────────────────

class _GitHubSettingsCard extends StatefulWidget {
  final HabitController ctrl;
  const _GitHubSettingsCard({required this.ctrl});

  @override
  State<_GitHubSettingsCard> createState() => _GitHubSettingsCardState();
}

class _GitHubSettingsCardState extends State<_GitHubSettingsCard> {
  late final TextEditingController _userCtrl;

  @override
  void initState() {
    super.initState();
    _userCtrl = TextEditingController(text: widget.ctrl.githubUsername.value);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SaasCard(
      padding: const EdgeInsets.all(24),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto-track GitHub commits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: widget.ctrl.enableGithubTracking.value,
                activeColor: AppTheme.primary,
                onChanged: (v) {
                  widget.ctrl.updateGitHubSettings(_userCtrl.text.trim(), v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _userCtrl,
            style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter GitHub username',
              labelText: 'GitHub Username',
              labelStyle: TextStyle(color: AppTheme.textSecondary(context), fontSize: 12),
              prefixIcon: Icon(Icons.code, color: AppTheme.textSecondary(context), size: 20),
            ),
            onChanged: (v) {
              widget.ctrl.updateGitHubSettings(v.trim(), widget.ctrl.enableGithubTracking.value);
            },
          ),
          if (widget.ctrl.enableGithubTracking.value) ...[
            const SizedBox(height: 24),
            SaasButton(
              text: widget.ctrl.isGithubSyncing.value ? 'Syncing...' : 'Sync GitHub Now',
              icon: Icons.sync,
              width: double.infinity,
              onPressed: widget.ctrl.isGithubSyncing.value
                  ? () {}
                  : () async {
                      await widget.ctrl.checkGitHubCommits();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('GitHub sync completed! checked for today\'s commits 🔔',
                                style: TextStyle(color: AppTheme.textPrimary(context))),
                            backgroundColor: AppTheme.cardColor(context),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
            ),
          ],
        ],
      )),
    );
  }
}

// ── Firebase Settings Widget ─────────────────────────────────────────────────

class _FirebaseSettingsCard extends StatelessWidget {
  const _FirebaseSettingsCard();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SyncService>()) {
      return _buildFallbackCard(context, 'SyncService is not initialized.');
    }

    final syncService = SyncService.to;
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (!syncService.isFirebaseAvailable.value) {
        return _buildFallbackCard(
          context,
          'Firebase is running in local-offline mode. Please configure Firebase options using flutterfire CLI to sync online.',
        );
      }

      final user = syncService.currentUser.value;

      return SaasCard(
        padding: const EdgeInsets.all(24),
        borderColor: AppTheme.success.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_done, color: AppTheme.success, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Backup Active',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Authenticated',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: syncService.isSyncing.value
                    ? const Center(
                        child: SizedBox(
                          height: 48,
                          width: 48,
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        ),
                      )
                    : SaasButton(
                        text: 'Sync Now',
                        icon: Icons.sync,
                        onPressed: () async {
                          if (user != null) {
                            await syncService.syncAll(user.uid);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Data sync complete! ☁️',
                                      style: TextStyle(color: AppTheme.textPrimary(context))),
                                  backgroundColor: AppTheme.cardColor(context),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: authController.isLoading.value ? null : () => authController.logout(),
                  icon: authController.isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.logout, size: 20),
                  label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: const BorderSide(color: AppTheme.accent, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFallbackCard(BuildContext context, String reason) {
    return SaasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off, color: AppTheme.accent, size: 24),
              const SizedBox(width: 12),
              Text('Cloud Sync Offline', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(reason, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ── Reminders Section ────────────────────────────────────────────────────────

class _RemindersSection extends StatelessWidget {
  final NotificationController ctrl;
  const _RemindersSection({required this.ctrl});

  String _formatTime(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  static const List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SaasCard(
      padding: EdgeInsets.zero,
      borderColor: AppTheme.accent.withOpacity(0.3),
      child: Obx(() => Column(
        children: [
          // Daily Habit Reminder
          _buildReminderTile(
            context,
            title: 'Daily Habit Reminder',
            subtitle: 'Reminds you to log habits',
            icon: Icons.checklist,
            enabled: ctrl.habitReminderEnabled.value,
            timeLabel: _formatTime(ctrl.habitHour.value, ctrl.habitMinute.value),
            onToggle: (v) => ctrl.updateHabitReminder(v, ctrl.habitHour.value, ctrl.habitMinute.value),
            onTimeTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: ctrl.habitHour.value, minute: ctrl.habitMinute.value),
              );
              if (picked != null) {
                ctrl.updateHabitReminder(ctrl.habitReminderEnabled.value, picked.hour, picked.minute);
              }
            },
          ),
          Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),

          // Weekly Review Reminder
          _buildReminderTile(
            context,
            title: 'Weekly Review Reminder',
            subtitle: 'Reflect on your progress',
            icon: Icons.auto_graph,
            enabled: ctrl.weeklyReminderEnabled.value,
            timeLabel: '${_daysOfWeek[ctrl.weeklyDayOfWeek.value - 1]} at ${_formatTime(ctrl.weeklyHour.value, ctrl.weeklyMinute.value)}',
            onToggle: (v) => ctrl.updateWeeklyReminder(v, ctrl.weeklyDayOfWeek.value, ctrl.weeklyHour.value, ctrl.weeklyMinute.value),
            onTimeTap: () async {
              int tempDay = ctrl.weeklyDayOfWeek.value;
              final pickedDay = await showDialog<int>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.cardColor(context),
                  title: Text('Select Day', style: TextStyle(color: AppTheme.textPrimary(context))),
                  content: DropdownButtonFormField<int>(
                    value: tempDay,
                    dropdownColor: AppTheme.cardColor(context),
                    items: List.generate(7, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(_daysOfWeek[i], style: TextStyle(color: AppTheme.textPrimary(context))),
                    )),
                    onChanged: (v) => tempDay = v ?? tempDay,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary(context)))),
                    TextButton(onPressed: () => Navigator.pop(ctx, tempDay), child: const Text('Next', style: TextStyle(color: AppTheme.primary))),
                  ],
                ),
              );

              if (pickedDay != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: ctrl.weeklyHour.value, minute: ctrl.weeklyMinute.value),
                );
                if (pickedTime != null) {
                  ctrl.updateWeeklyReminder(ctrl.weeklyReminderEnabled.value, pickedDay, pickedTime.hour, pickedTime.minute);
                }
              }
            },
          ),
          Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),

          // Motivational Streak
          _buildReminderTile(
            context,
            title: 'Morning Motivation',
            subtitle: 'Daily streak updates',
            icon: Icons.local_fire_department,
            enabled: ctrl.streakMotivationEnabled.value,
            timeLabel: _formatTime(ctrl.streakHour.value, ctrl.streakMinute.value),
            onToggle: (v) => ctrl.updateStreakMotivation(v, ctrl.streakHour.value, ctrl.streakMinute.value, Get.find<HabitController>().longestCurrentStreak),
            onTimeTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: ctrl.streakHour.value, minute: ctrl.streakMinute.value),
              );
              if (picked != null) {
                ctrl.updateStreakMotivation(ctrl.streakMotivationEnabled.value, picked.hour, picked.minute, Get.find<HabitController>().longestCurrentStreak);
              }
            },
          ),
        ],
      )),
    );
  }

  Widget _buildReminderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required String timeLabel,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeColor: AppTheme.accent,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
        if (enabled)
          InkWell(
            onTap: onTimeTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Time', style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
