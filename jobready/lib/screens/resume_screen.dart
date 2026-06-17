import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resume_controller.dart';
import '../theme/app_theme.dart';

class ResumeScreen extends StatelessWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily initialize controller if not already done
    final controller = Get.put(ResumeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Analyzer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(context, controller),
            const SizedBox(height: 24),
            _buildAnalyzeButton(context, controller),
            const SizedBox(height: 32),
            _buildResultsSection(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, ResumeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() => SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'paste',
              label: Text('Paste Text'),
              icon: Icon(Icons.text_fields),
            ),
            ButtonSegment<String>(
              value: 'pdf',
              label: Text('Upload PDF'),
              icon: Icon(Icons.picture_as_pdf),
            ),
          ],
          selected: {controller.inputMode.value},
          onSelectionChanged: (Set<String> newSelection) {
            controller.toggleInputMode(newSelection.first);
          },
        )),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.inputMode.value == 'paste') {
            return TextField(
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Paste your resume here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppTheme.cardColor(context),
              ),
              onChanged: (val) => controller.resumeText.value = val,
            );
          } else {
            return GestureDetector(
              onTap: controller.pickPdf,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      controller.pickedFileName.value.isEmpty
                          ? 'Tap to select PDF'
                          : controller.pickedFileName.value,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, ResumeController controller) {
    return Obx(() {
      final isEnabled = controller.resumeText.value.trim().isNotEmpty && !controller.isAnalyzing.value;
      return ElevatedButton(
        onPressed: isEnabled ? controller.analyze : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        child: controller.isAnalyzing.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Analyze Resume 🔍',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      );
    });
  }

  Widget _buildResultsSection(BuildContext context, ResumeController controller) {
    return Obx(() {
      final result = controller.result.value;
      if (result == null) return const SizedBox.shrink();

      Map<String, dynamic> feedbackMap = {};
      try {
        feedbackMap = jsonDecode(result.sectionFeedback);
      } catch (e) {
        debugPrint('Failed to decode feedback map: $e');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Analysis Results',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCircular('Overall Score', result.overallScore, context),
              _buildScoreCircular('ATS Score', result.atsScore, context),
            ],
          ),
          const SizedBox(height: 24),
          
          // Section Feedback
          const Text(
            'Section Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (feedbackMap['summary'] != null)
            _buildFeedbackCard('Summary', feedbackMap['summary'], context),
          if (feedbackMap['skills'] != null)
            _buildFeedbackCard('Skills', feedbackMap['skills'], context),
          if (feedbackMap['experience'] != null)
            _buildFeedbackCard('Experience', feedbackMap['experience'], context),
          if (feedbackMap['education'] != null)
            _buildFeedbackCard('Education', feedbackMap['education'], context),
            
          const SizedBox(height: 24),
          
          // Keyword Gaps
          if (result.keywordGaps.isNotEmpty) ...[
            const Text(
              '⚠️ Missing Keywords',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.keywordGaps.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.red),
                );
              }).toList(),
            ),
          ]
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
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: scoreColor,
                strokeWidth: 8,
              ),
            ),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(String title, String content, BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.divider(context)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
