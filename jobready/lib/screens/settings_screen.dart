import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/habit_controller.dart';
import '../services/notification_service.dart';
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
