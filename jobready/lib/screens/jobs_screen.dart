import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static const _statuses = ['applied', 'interview', 'offer', 'rejected', 'ghosted'];
  static const _statusLabels = {
    'applied': '📨 Applied',
    'interview': '🎯 Interview',
    'offer': '🎉 Offer',
    'rejected': '❌ Rejected',
    'ghosted': '👻 Ghosted',
  };
  static const _statusColors = {
    'applied': AppTheme.primary,
    'interview': AppTheme.warning,
    'offer': AppTheme.success,
    'rejected': AppTheme.error,
    'ghosted': AppTheme.textMuted, // updated to use theme constant equivalent
  };

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddJobSheet(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.jobs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.work_outline, color: AppTheme.primary, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text('No applications yet bro',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Tap + to add your first one',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 32),
                    GradientButton(
                      text: 'Add application',
                      icon: Icons.add,
                      onPressed: () => _showAddJobSheet(context, ctrl),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Stats row
            Row(
              children: [
                _StatPill(label: 'Total', value: '${ctrl.jobs.length}', color: AppTheme.primary),
                const SizedBox(width: 12),
                _StatPill(label: 'Active', value: '${ctrl.activeApplications}', color: AppTheme.secondary),
                const SizedBox(width: 12),
                _StatPill(
                  label: 'Offers',
                  value: '${ctrl.jobs.where((j) => j.status == 'offer').length}',
                  color: AppTheme.success,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Group by status
            ..._statuses.map((status) {
              final group = ctrl.jobs.where((j) => j.status == status).toList();
              if (group.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: _statusLabels[status]!),
                  const SizedBox(height: 16),
                  ...group.map((job) => _JobCard(
                        job: job,
                        ctrl: ctrl,
                        statusColors: _statusColors,
                        statusLabels: _statusLabels,
                        statuses: _statuses,
                      )),
                  const SizedBox(height: 24),
                ],
              );
            }),
            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }

  void _showAddJobSheet(BuildContext context, HabitController ctrl) {
    final companyCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add application',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextField(
              controller: companyCtrl,
              autofocus: true,
              style: TextStyle(color: AppTheme.textPrimary(context)),
              decoration: const InputDecoration(hintText: 'Company name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roleCtrl,
              style: TextStyle(color: AppTheme.textPrimary(context)),
              decoration: const InputDecoration(hintText: 'Role / position'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlCtrl,
              style: TextStyle(color: AppTheme.textPrimary(context)),
              decoration: const InputDecoration(hintText: 'Job URL (optional)'),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Add application',
              width: double.infinity,
              onPressed: () {
                if (companyCtrl.text.trim().isNotEmpty &&
                    roleCtrl.text.trim().isNotEmpty) {
                  ctrl.addJob(
                    companyCtrl.text.trim(),
                    roleCtrl.text.trim(),
                    url: urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim(),
                  );
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

class _JobCard extends StatelessWidget {
  final JobModel job;
  final HabitController ctrl;
  final Map<String, Color> statusColors;
  final Map<String, String> statusLabels;
  final List<String> statuses;

  const _JobCard({
    required this.job,
    required this.ctrl,
    required this.statusColors,
    required this.statusLabels,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    // If not found in map, fallback
    final color = statusColors[job.status] ?? AppTheme.textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    job.company[0].toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
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
                    Text(job.role, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppTheme.cardColor(context),
                icon: Icon(Icons.more_vert,
                    color: AppTheme.textSecondary(context), size: 20),
                onSelected: (s) {
                  if (s == 'delete') {
                    ctrl.deleteJob(job);
                  } else {
                    ctrl.updateJobStatus(job, s);
                  }
                },
                itemBuilder: (_) => [
                  ...statuses.map((s) => PopupMenuItem(
                        value: s,
                        child: Text(statusLabels[s]!,
                            style: TextStyle(
                                color: AppTheme.textPrimary(context), fontSize: 14, fontWeight: FontWeight.w500)),
                      )),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(
                            color: AppTheme.error, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applied: ${job.appliedDate}',
                style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabels[job.status] ?? 'Unknown',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: AppTheme.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
