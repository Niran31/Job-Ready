import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/interview_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/saas_card.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final ScrollController _scrollController = ScrollController();
  late Worker _questionsWorker;
  late Worker _resultWorker;

  @override
  void initState() {
    super.initState();
    // Lazily put the controller here
    final controller = Get.put(InterviewController());
    
    // Set up scroll-to-top listeners when phase transitions happen
    _questionsWorker = ever(controller.questionsGenerated, (_) => _scrollToTop());
    _resultWorker = ever(controller.result, (_) => _scrollToTop());
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _questionsWorker.dispose();
    _resultWorker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterviewController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Interview Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          final result = controller.result.value;
          final questionsGenerated = controller.questionsGenerated.value;

          if (result != null) {
            return _buildResultsPhase(context, controller);
          } else if (questionsGenerated) {
            return _buildAnsweringPhase(context, controller);
          } else {
            return _buildSetupPhase(context, controller);
          }
        }),
      ),
    );
  }

  // ── Phase 1: Setup ─────────────────────────────────────────────────────────

  Widget _buildSetupPhase(BuildContext context, InterviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Interview Setup',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your data source and generate target interview questions.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary(context),
          ),
        ),
        const SizedBox(height: 24),
        
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: true,
              label: Text('Use Last JD & Resume'),
              icon: Icon(Icons.history_edu),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text('Enter Manually'),
              icon: Icon(Icons.edit_note),
            ),
          ],
          selected: {controller.usingLastData.value},
          onSelectionChanged: (Set<bool> newSelection) {
            controller.toggleDataSource(newSelection.first);
          },
        ),
        const SizedBox(height: 24),

        if (controller.usingLastData.value) ...[
          // Resume snippet
          Card(
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
                        'Loaded Resume',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      _buildLoadedBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.resumeText.value.isEmpty
                        ? 'No resume snippet loaded.'
                        : controller.resumeText.value,
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // JD snippet
          Card(
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
                        'Loaded Job Description',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      _buildLoadedBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.jobDescription.value.isEmpty
                        ? 'No job description snippet loaded.'
                        : controller.jobDescription.value,
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Manual input
          Text(
            'Resume Text',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context)),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Paste your resume text here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.cardColor(context),
            ),
            onChanged: (val) => controller.resumeText.value = val,
          ),
          const SizedBox(height: 20),
          Text(
            'Job Description',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context)),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Paste the target job description here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.cardColor(context),
            ),
            onChanged: (val) => controller.jobDescription.value = val,
          ),
        ],
        const SizedBox(height: 28),


        ElevatedButton(
          onPressed: controller.isGenerating.value ? null : controller.generateQuestions,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
          ),
          child: controller.isGenerating.value
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Generating questions...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : const Text(
                  'Generate Questions 🎯',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildLoadedBadge() {
    return Container(
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
    );
  }

  // ── Phase 2: Answering questions ───────────────────────────────────────────

  Widget _buildAnsweringPhase(BuildContext context, InterviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SaasCard(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primary.withOpacity(0.05),
          child: Row(
            children: [
              const Icon(Icons.mic, color: AppTheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interview Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Answer all questions, then submit for AI feedback',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Column(
          children: List.generate(controller.questions.length, (index) {
            final isTechnical = index >= 4;
            final qNumber = index + 1;
            final categoryText = isTechnical ? 'Technical' : 'HR/Behavioral';
            final categoryColor = isTechnical ? Colors.amber[800]! : Colors.indigo;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SaasCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(
                            'Q$qNumber',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categoryText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.questions[index],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 4,
                      style: TextStyle(color: AppTheme.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Type your answer here...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: AppTheme.cardColor(context).withOpacity(0.5),
                      ),
                      onChanged: (val) => controller.updateAnswer(index, val),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),
        Obx(() {
          final allAnswered = controller.userAnswers.every((ans) => ans.trim().isNotEmpty);
          final isEnabled = allAnswered && !controller.isEvaluating.value;

          return ElevatedButton(
            onPressed: isEnabled ? controller.evaluateAnswers : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
            ),
            child: controller.isEvaluating.value
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Evaluating answers...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : const Text(
                    'Submit for Feedback 📝',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          );
        }),
        const SizedBox(height: 12),
        TextButton(
          onPressed: controller.isEvaluating.value ? null : controller.resetSession,
          child: const Text('Cancel & Reset'),
        ),
      ],
    );
  }

  // ── Phase 3: Results ───────────────────────────────────────────────────────

  Widget _buildResultsPhase(BuildContext context, InterviewController controller) {
    final result = controller.result.value!;
    
    Color scoreColor;
    if (result.overallScore >= 80) {
      scoreColor = Colors.green;
    } else if (result.overallScore >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall score circular indicator
        Card(
          elevation: 0,
          color: AppTheme.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.divider(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: result.overallScore / 100,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        color: scoreColor,
                        strokeWidth: 10,
                      ),
                    ),
                    Text(
                      '${result.overallScore}%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Overall Interview Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Overall Performance Summary
        Card(
          elevation: 0,
          color: AppTheme.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.divider(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💬 Performance Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.overallSummary,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Question Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),

        // Per-Question feedback list
        Column(
          children: List.generate(result.questions.length, (index) {
            final question = result.questions[index];
            final answer = result.userAnswers[index];
            final qScore = result.answerScores[index];
            final qFeedback = result.answerFeedback[index];
            final qNumber = index + 1;

            Color qScoreColor;
            if (qScore >= 8) {
              qScoreColor = Colors.green;
            } else if (qScore >= 6) {
              qScoreColor = Colors.orange;
            } else {
              qScoreColor = Colors.red;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                color: AppTheme.cardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.divider(context)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(
                            '$qNumber',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: qScoreColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$qScore/10',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: qScoreColor,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(height: 16),
                            Text(
                              'Full Question:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Answer:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              answer,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      qFeedback,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: controller.resetSession,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Start New Session 🎯',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
