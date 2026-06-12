import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/habit_controller.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../widgets/section_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lazyModeEnabled = true;
  int _alarmHour = 10;
  int _alarmMinute = 0;
  String _userName = 'Niran';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lazyModeEnabled = prefs.getBool('lazyMode') ?? true;
      _alarmHour = prefs.getInt('alarmHour') ?? 10;
      _alarmMinute = prefs.getInt('alarmMinute') ?? 0;
      _userName = prefs.getString('userName') ?? 'Niran';
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lazyMode', _lazyModeEnabled);
    await prefs.setInt('alarmHour', _alarmHour);
    await prefs.setInt('alarmMinute', _alarmMinute);
    await prefs.setString('userName', _userName);

    if (_lazyModeEnabled) {
      await NotificationService.scheduleDailyCheckIn(
          hour: _alarmHour, minute: _alarmMinute);
    } else {
      await NotificationService.cancelCheckIn();
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

          // Lazy mode section
          SectionHeader(title: '⚠️ Lazy mode blocker'),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            borderColor: _lazyModeEnabled
                ? AppTheme.accent.withOpacity(0.3)
                : AppTheme.textSecondary(context).withOpacity(0.1),
            child: Column(
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
                        child: const Icon(Icons.alarm, color: AppTheme.accent, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Daily check-in alarm',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'If you haven\'t logged by this time — BUZZ!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _lazyModeEnabled,
                        activeColor: AppTheme.accent,
                        onChanged: (v) {
                          setState(() => _lazyModeEnabled = v);
                          _savePrefs();
                        },
                      ),
                    ],
                  ),
                ),
                if (_lazyModeEnabled) ...[
                  Divider(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight, height: 1),
                  InkWell(
                    onTap: () => _pickAlarmTime(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Alarm time',
                              style: TextStyle(
                                  color: AppTheme.textPrimary(context),
                                  fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatTime(_alarmHour, _alarmMinute),
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This alarm fires every day at your set time if you haven\'t checked off any habits. Stay accountable bro! 🔥',
            style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 13,
                height: 1.5),
          ),

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

  void _pickAlarmTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _alarmHour, minute: _alarmMinute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _alarmHour = picked.hour;
        _alarmMinute = picked.minute;
      });
      await _savePrefs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Alarm set for ${_formatTime(_alarmHour, _alarmMinute)} 🔔'),
          backgroundColor: AppTheme.cardColor(context),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
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
    return GlassCard(
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
    
    return GlassCard(
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
    return GlassCard(
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
            GradientButton(
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
                            content: const Text('GitHub sync completed! checked for today\'s commits 🔔'),
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

class _FirebaseSettingsCard extends StatefulWidget {
  const _FirebaseSettingsCard();

  @override
  State<_FirebaseSettingsCard> createState() => _FirebaseSettingsCardState();
}

class _FirebaseSettingsCardState extends State<_FirebaseSettingsCard> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final syncService = SyncService.to;

    try {
      if (_isLogin) {
        await syncService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await syncService.signUp(_emailCtrl.text.trim(), _passwordCtrl.text);
      }

      _emailCtrl.clear();
      _passwordCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Logged in successfully! 🎉' : 'Account created and synced! 🚀'),
            backgroundColor: AppTheme.cardColor(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth error: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '')}'),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SyncService>()) {
      return _buildFallbackCard(context, 'SyncService is not initialized.');
    }

    final syncService = SyncService.to;

    return Obx(() {
      if (!syncService.isFirebaseAvailable.value) {
        return _buildFallbackCard(
          context,
          'Firebase is running in local-offline mode. Please configure Firebase options using flutterfire CLI to sync online.',
        );
      }

      final user = syncService.currentUser.value;

      if (user != null) {
        return GlassCard(
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
                          user.email ?? 'Authenticated',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      text: syncService.isSyncing.value ? 'Syncing...' : 'Sync Now',
                      icon: Icons.sync,
                      onPressed: syncService.isSyncing.value
                          ? () {}
                          : () async {
                              await syncService.syncAll(user.uid);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Data sync complete! ☁️'),
                                    backgroundColor: AppTheme.cardColor(context),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => syncService.logout(),
                    icon: const Icon(Icons.logout, size: 20),
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
      }

      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Sign in to Cloud Sync' : 'Create Sync Account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: AppTheme.textSecondary(context), fontSize: 12),
                  prefixIcon: Icon(Icons.email, color: AppTheme.textSecondary(context), size: 20),
                ),
                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: AppTheme.textSecondary(context), fontSize: 12),
                  prefixIcon: Icon(Icons.lock, color: AppTheme.textSecondary(context), size: 20),
                ),
                validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: _isLogin ? 'Sign In' : 'Register',
                width: double.infinity,
                onPressed: _loading ? () {} : _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Sign In',
                    style: const TextStyle(color: AppTheme.secondary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFallbackCard(BuildContext context, String reason) {
    return GlassCard(
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
