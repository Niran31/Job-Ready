import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';

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
    'rejected': AppTheme.accent,
    'ghosted': AppTheme.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HabitController>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_outline,
                    color: AppTheme.textSecondary, size: 48),
                const SizedBox(height: 12),
                Text('No applications yet bro',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text('Tap + to add your first one',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showAddJobSheet(context, ctrl),
                  icon: const Icon(Icons.add),
                  label: const Text('Add application'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Stats row
            Row(
              children: [
                _StatPill(label: 'Total', value: '${ctrl.jobs.length}', color: AppTheme.primary),
                const SizedBox(width: 8),
                _StatPill(label: 'Active', value: '${ctrl.activeApplications}', color: AppTheme.secondary),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'Offers',
                  value: '${ctrl.jobs.where((j) => j.status == 'offer').length}',
                  color: AppTheme.success,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Group by status
            ..._statuses.map((status) {
              final group = ctrl.jobs.where((j) => j.status == status).toList();
              if (group.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: _statusLabels[status]!),
                  const SizedBox(height: 10),
                  ...group.map((job) => _JobCard(
                        job: job,
                        ctrl: ctrl,
                        statusColors: _statusColors,
                        statusLabels: _statusLabels,
                        statuses: _statuses,
                      )),
                  const SizedBox(height: 20),
                ],
              );
            }),
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
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add application',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: companyCtrl,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Company name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Role / position'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Job URL (optional)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                child: const Text('Add application'),
              ),
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
    final color = statusColors[job.status] ?? AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(job.company,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              PopupMenuButton<String>(
                color: AppTheme.bgCardLight,
                icon: const Icon(Icons.more_vert,
                    color: AppTheme.textSecondary, size: 18),
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
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 13)),
                      )),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(
                            color: AppTheme.accent, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
          Text(job.role, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'Applied: ${job.appliedDate}',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
