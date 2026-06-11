import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/habit_controller.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile section
          _SectionTitle(title: 'Profile'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Your name',
            trailing: Text(_userName,
                style: const TextStyle(color: AppTheme.textSecondary)),
            onTap: () => _showNameDialog(),
          ),

          const SizedBox(height: 24),

          // Targets section
          _SectionTitle(title: '🎯 Weekly career targets'),
          _TargetsContainer(ctrl: Get.find<HabitController>()),

          const SizedBox(height: 24),

          // Lazy mode section
          _SectionTitle(title: '⚠️ Lazy mode blocker'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _lazyModeEnabled
                    ? AppTheme.accent.withOpacity(0.3)
                    : AppTheme.textSecondary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm,
                          color: AppTheme.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily check-in alarm',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            Text(
                              'If you haven\'t logged by this time — BUZZ!',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12),
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
                  const Divider(
                      color: AppTheme.bgCardLight, height: 1),
                  InkWell(
                    onTap: () => _pickAlarmTime(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Alarm time',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            _formatTime(_alarmHour, _alarmMinute),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
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

          const SizedBox(height: 12),
          const Text(
            'This alarm fires every day at your set time if you haven\'t checked off any habits. Stay accountable bro! 🔥',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.5),
          ),

          const SizedBox(height: 32),

          // GitHub tracking section
          _SectionTitle(title: '💻 GitHub Commit Auto-Tracker'),
          _GitHubSettingsCard(ctrl: Get.find<HabitController>()),

          const SizedBox(height: 24),

          // Firebase sync section
          _SectionTitle(title: '☁️ Firebase Cloud Sync'),
          const _FirebaseSettingsCard(),

          const SizedBox(height: 32),

          // About
          _SectionTitle(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App version',
            trailing: const Text('1.0.0',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          _SettingsTile(
            icon: Icons.code,
            title: 'Built by',
            trailing: const Text('Niran × Velzyn Labs',
                style: TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600)),
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
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
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
          backgroundColor: AppTheme.bgCard,
        ));
      }
    }
  }

  void _showNameDialog() {
    final ctrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Your name',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              setState(() => _userName = ctrl.text.trim());
              _savePrefs();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
          title: Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500)),
          trailing: trailing,
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
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
          const Divider(color: AppTheme.bgCardLight, height: 1),
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
          const Divider(color: AppTheme.bgCardLight, height: 1),
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
          const Divider(color: AppTheme.bgCardLight, height: 1),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.secondary, size: 20),
                onPressed: onDecrement,
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    valueText,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 20),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Auto-track GitHub commits',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
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
          const SizedBox(height: 8),
          TextField(
            controller: _userCtrl,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Enter GitHub username',
              labelText: 'GitHub Username',
              labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              prefixIcon: Icon(Icons.code, color: AppTheme.textSecondary, size: 20),
            ),
            onChanged: (v) {
              widget.ctrl.updateGitHubSettings(v.trim(), widget.ctrl.enableGithubTracking.value);
            },
          ),
          if (widget.ctrl.enableGithubTracking.value) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.ctrl.isGithubSyncing.value
                    ? null
                    : () async {
                        await widget.ctrl.checkGitHubCommits();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('GitHub sync completed! checked for today\'s commits 🔔'),
                              backgroundColor: AppTheme.bgCard,
                            ),
                          );
                        }
                      },
                icon: widget.ctrl.isGithubSyncing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync, size: 18),
                label: Text(widget.ctrl.isGithubSyncing.value ? 'Syncing...' : 'Sync GitHub Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bgCardLight,
                  foregroundColor: AppTheme.textPrimary,
                ),
              ),
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
            backgroundColor: AppTheme.bgCard,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth error: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '')}'),
            backgroundColor: AppTheme.accent.withOpacity(0.8),
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
      return _buildFallbackCard(reason: 'SyncService is not initialized.');
    }

    final syncService = SyncService.to;

    return Obx(() {
      if (!syncService.isFirebaseAvailable.value) {
        return _buildFallbackCard(
          reason: 'Firebase is running in local-offline mode. Please configure Firebase options using flutterfire CLI to sync online.',
        );
      }

      final user = syncService.currentUser.value;

      if (user != null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.success.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_done, color: AppTheme.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cloud Backup Active',
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.email ?? 'Authenticated',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: syncService.isSyncing.value
                          ? null
                          : () async {
                              await syncService.syncAll(user.uid);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Data sync complete! ☁️'),
                                    backgroundColor: AppTheme.bgCard,
                                  ),
                                );
                              }
                            },
                      icon: syncService.isSyncing.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sync, size: 16),
                      label: Text(syncService.isSyncing.value ? 'Syncing...' : 'Sync Now'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => syncService.logout(),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1), width: 1),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Sign in to Cloud Sync' : 'Create Sync Account',
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  prefixIcon: Icon(Icons.email, color: AppTheme.textSecondary, size: 18),
                ),
                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  prefixIcon: Icon(Icons.lock, color: AppTheme.textSecondary, size: 18),
                ),
                validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(_isLogin ? 'Sign In' : 'Register'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Sign In',
                    style: const TextStyle(color: AppTheme.secondary, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFallbackCard({required String reason}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cloud_off, color: AppTheme.warning, size: 24),
              SizedBox(width: 12),
              Text(
                'Cloud Sync Offline',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reason,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

