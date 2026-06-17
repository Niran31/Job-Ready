import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/interview_session_model.dart';
import '../models/resume_result_model.dart';
import '../models/job_match_result_model.dart';
import '../services/interview_service.dart';
import 'resume_controller.dart';
import 'job_match_controller.dart';

class InterviewController extends GetxController {
  final RxString resumeText = ''.obs;
  final RxString jobDescription = ''.obs;
  final RxBool usingLastData = true.obs;
  final RxBool isGenerating = false.obs;
  final RxBool isEvaluating = false.obs;
  final RxList<String> questions = <String>[].obs;
  final RxList<String> userAnswers = <String>[].obs;
  final RxBool questionsGenerated = false.obs;
  final Rx<InterviewSessionModel?> result = Rx<InterviewSessionModel?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    try {
      final hasResume = _loadLastResume();
      final hasJob = _loadLastJobDescription();
      
      if (hasResume && hasJob) {
        usingLastData.value = true;
      } else {
        usingLastData.value = false;
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      usingLastData.value = false;
    }
  }

  bool _loadLastResume() {
    final box = Hive.box<ResumeResultModel>('resume_results');
    if (box.isNotEmpty) {
      final results = box.values.toList()
        ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      resumeText.value = results.first.resumeTextSnippet;
      return true;
    }
    return false;
  }

  bool _loadLastJobDescription() {
    final box = Hive.box<JobMatchResultModel>('job_match_results');
    if (box.isNotEmpty) {
      final results = box.values.toList()
        ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      jobDescription.value = results.first.jobDescriptionSnippet;
      return true;
    }
    return false;
  }

  void toggleDataSource(bool useLast) {
    usingLastData.value = useLast;
    errorMessage.value = '';
    
    if (useLast) {
      final hasResume = _loadLastResume();
      final hasJob = _loadLastJobDescription();
      if (!hasResume || !hasJob) {
        resumeText.value = '';
        jobDescription.value = '';
        usingLastData.value = false;
        Get.snackbar(
          'No Prior Analysis',
          'Please complete a resume analysis and job matching first, or enter data manually.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      resumeText.value = '';
      jobDescription.value = '';
    }
  }

  Future<void> generateQuestions() async {
    String finalResumeText = '';
    String finalJobDescription = '';

    if (usingLastData.value) {
      // Attempt to load full texts from controllers in memory
      final resumeCtrl = Get.isRegistered<ResumeController>()
          ? Get.find<ResumeController>()
          : Get.put(ResumeController());
      
      final jobMatchCtrl = Get.isRegistered<JobMatchController>()
          ? Get.find<JobMatchController>()
          : Get.put(JobMatchController());

      if (resumeCtrl.resumeText.value.trim().isNotEmpty) {
        finalResumeText = resumeCtrl.resumeText.value;
      } else {
        finalResumeText = resumeText.value; // Fallback to snippet from Hive
      }

      if (jobMatchCtrl.jobDescription.value.trim().isNotEmpty) {
        finalJobDescription = jobMatchCtrl.jobDescription.value;
      } else {
        finalJobDescription = jobDescription.value; // Fallback to snippet from Hive
      }
    } else {
      finalResumeText = resumeText.value;
      finalJobDescription = jobDescription.value;
    }

    if (finalResumeText.trim().isEmpty) {
      errorMessage.value = 'Please provide resume text.';
      return;
    }

    if (finalJobDescription.trim().isEmpty) {
      errorMessage.value = 'Please provide a job description.';
      return;
    }

    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final generatedQuestions = await InterviewService.generateQuestions(
        finalResumeText,
        finalJobDescription,
      );

      questions.assignAll(generatedQuestions);
      userAnswers.assignAll(List.generate(generatedQuestions.length, (_) => ''));
      questionsGenerated.value = true;
    } catch (e) {
      debugPrint('Error generating questions: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Generation Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  void updateAnswer(int index, String answer) {
    if (index >= 0 && index < userAnswers.length) {
      userAnswers[index] = answer;
    }
  }

  Future<void> evaluateAnswers() async {
    // Validate all answers are non-empty
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i].trim().isEmpty) {
        Get.snackbar(
          'Incomplete Answers',
          'Please answer all questions before submitting.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    try {
      isEvaluating.value = true;
      errorMessage.value = '';

      final evaluationData = await InterviewService.evaluateAnswers(
        questions.toList(),
        userAnswers.toList(),
      );

      final List<int> scores = List<int>.from(evaluationData['answerScores']);
      final List<String> feedback = List<String>.from(evaluationData['answerFeedback']);
      final int score = evaluationData['overallScore'] ?? 0;
      final String summary = evaluationData['overallSummary'] ?? '';

      final String snippet = jobDescription.value.length > 100
          ? '${jobDescription.value.substring(0, 100)}...'
          : jobDescription.value;

      final sessionResult = InterviewSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionDate: DateTime.now(),
        jobDescriptionSnippet: snippet,
        questions: questions.toList(),
        userAnswers: userAnswers.toList(),
        answerScores: scores,
        answerFeedback: feedback,
        overallScore: score,
        overallSummary: summary,
      );

      // Save to Hive
      final box = Hive.box<InterviewSessionModel>('interview_sessions');
      await box.put(sessionResult.id, sessionResult);

      result.value = sessionResult;
    } catch (e) {
      debugPrint('Error evaluating answers: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Evaluation Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isEvaluating.value = false;
    }
  }

  void resetSession() {
    questions.clear();
    userAnswers.clear();
    questionsGenerated.value = false;
    result.value = null;
    errorMessage.value = '';
    _loadInitialData();
  }
}
