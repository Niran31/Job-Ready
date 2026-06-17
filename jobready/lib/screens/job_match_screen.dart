import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_match_controller.dart';
import '../theme/app_theme.dart';

class JobMatchScreen extends StatelessWidget {
  const JobMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily initialize controller if not already done
    final controller = Get.put(JobMatchController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Match Scorer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResumeSourceSection(context, controller),
            const SizedBox(height: 24),
            _buildJobDescriptionSection(context, controller),
            const SizedBox(height: 24),
            _buildMatchButton(context, controller),
            const SizedBox(height: 32),
            _buildResultsSection(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeSourceSection(BuildContext context, JobMatchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resume Source',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: true,
              label: Text('Last Analyzed'),
              icon: Icon(Icons.history_edu),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text('Paste Manually'),
              icon: Icon(Icons.edit_note),
            ),
          ],
          selected: {controller.usingLastResume.value},
          onSelectionChanged: (Set<bool> newSelection) {
            controller.toggleResumeSource(newSelection.first);
          },
        )),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.usingLastResume.value) {
            return Card(
              elevation: 0,
              color: AppTheme.cardColor(context).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.divider(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Loaded Resume Snippet',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 12, color: AppTheme.success),
                              SizedBox(width: 4),
                              Text(
                                '✓ Loaded',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.resumeText.value.isEmpty
                          ? 'No past resume analysis found. Please paste it manually or analyze a resume first.'
                          : controller.resumeText.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary(context),
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return TextField(
              maxLines: 6,
              style: TextStyle(color: AppTheme.textPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Paste your resume text here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppTheme.cardColor(context),
              ),
              onChanged: (val) => controller.resumeText.value = val,
            );
          }
        }),
      ],
    );
  }

  Widget _buildJobDescriptionSection(BuildContext context, JobMatchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 8,
          style: TextStyle(color: AppTheme.textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Paste the full job description here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.cardColor(context),
          ),
          onChanged: (val) => controller.jobDescription.value = val,
        ),
      ],
    );
  }

  Widget _buildMatchButton(BuildContext context, JobMatchController controller) {
    return Obx(() {
      final isEnabled = controller.jobDescription.value.trim().isNotEmpty && !controller.isAnalyzing.value;
      return ElevatedButton(
        onPressed: isEnabled ? controller.analyze : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
        ),
        child: controller.isAnalyzing.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Match Resume to JD 🎯',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      );
    });
  }

  Widget _buildResultsSection(BuildContext context, JobMatchController controller) {
    return Obx(() {
      final result = controller.result.value;
      if (result == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Match Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 24),
          
          // Match Score Card
          Center(child: _buildScoreCircular('Match Score', result.matchScore, context)),
          const SizedBox(height: 28),
          
          // Role Fit Summary
          Card(
            elevation: 0,
            color: AppTheme.cardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.divider(context)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🧠', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Role Fit Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.roleFitSummary,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Matched Keywords
          if (result.matchedKeywords.isNotEmpty) ...[
            Text(
              '✅ Matched Keywords',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.matchedKeywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  side: BorderSide(color: Colors.green.withOpacity(0.2)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Missing Keywords
          if (result.missingKeywords.isNotEmpty) ...[
            Text(
              '⚠️ Missing Keywords',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.missingKeywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                  side: BorderSide(color: Colors.red.withOpacity(0.2)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 32),
        ],
      );
    });
  }

  Widget _buildScoreCircular(String label, int score, BuildContext context) {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: scoreColor,
                strokeWidth: 10,
              ),
            ),
            Text(
              '$score%',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary(context),
          ),
        ),
      ],
    );
  }
}
