import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/job_match_result_model.dart';
import '../models/resume_result_model.dart';
import '../services/job_match_service.dart';
import 'resume_controller.dart';

class JobMatchController extends GetxController {
  final RxString resumeText = ''.obs;
  final RxString jobDescription = ''.obs;
  final RxBool isAnalyzing = false.obs;
  final RxBool usingLastResume = true.obs;
  final Rx<JobMatchResultModel?> result = Rx<JobMatchResultModel?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialResume();
    _loadLastMatchResult();
  }

  void _loadInitialResume() {
    try {
      final box = Hive.box<ResumeResultModel>('resume_results');
      if (box.isNotEmpty) {
        // Sort by analyzedAt descending to find the latest
        final results = box.values.toList()
          ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
        final latest = results.first;
        
        // Load snippet as initial text
        resumeText.value = latest.resumeTextSnippet;
        usingLastResume.value = true;
      } else {
        usingLastResume.value = false;
      }
    } catch (e) {
      debugPrint('Error loading last resume: $e');
      usingLastResume.value = false;
    }
  }

  void _loadLastMatchResult() {
    try {
      final box = Hive.box<JobMatchResultModel>('job_match_results');
      if (box.isNotEmpty) {
        final results = box.values.toList()
          ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
        result.value = results.first;
      }
    } catch (e) {
      debugPrint('Error loading last job match result: $e');
    }
  }

  void toggleResumeSource(bool useLastResume) {
    usingLastResume.value = useLastResume;
    errorMessage.value = '';
    
    if (useLastResume) {
      // Auto-load text from ResumeController if registered/in memory, otherwise from Hive
      final resumeController = Get.isRegistered<ResumeController>()
          ? Get.find<ResumeController>()
          : Get.put(ResumeController());
          
      if (resumeController.resumeText.value.trim().isNotEmpty) {
        resumeText.value = resumeController.resumeText.value;
      } else {
        // Fallback to loading the latest result snippet from Hive
        final box = Hive.box<ResumeResultModel>('resume_results');
        if (box.isNotEmpty) {
          final results = box.values.toList()
            ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
          resumeText.value = results.first.resumeTextSnippet;
        } else {
          resumeText.value = '';
          usingLastResume.value = false;
          Get.snackbar(
            'No Resume Found',
            'Please analyze your resume first or paste it manually.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } else {
      // Clear or keep empty for manual paste
      resumeText.value = '';
    }
  }

  Future<void> analyze() async {
    final String finalResumeText;
    if (usingLastResume.value) {
      final resumeController = Get.isRegistered<ResumeController>()
          ? Get.find<ResumeController>()
          : Get.put(ResumeController());
          
      if (resumeController.resumeText.value.trim().isNotEmpty) {
        finalResumeText = resumeController.resumeText.value;
      } else {
        finalResumeText = resumeText.value;
      }
    } else {
      finalResumeText = resumeText.value;
    }

    if (finalResumeText.trim().isEmpty) {
      errorMessage.value = 'Please provide resume text.';
      return;
    }

    if (jobDescription.value.trim().isEmpty) {
      errorMessage.value = 'Please paste a job description.';
      return;
    }

    try {
      isAnalyzing.value = true;
      errorMessage.value = '';

      final generatedResult = await JobMatchService.matchResumeToJD(
        finalResumeText,
        jobDescription.value,
      );

      // Save to Hive
      final box = Hive.box<JobMatchResultModel>('job_match_results');
      await box.put(generatedResult.id, generatedResult);

      result.value = generatedResult;
    } catch (e) {
      debugPrint('Job Match Error: $e');
      final errorString = e.toString();
      final hasConnError = [
        'SocketException', 'SocketFailed', 'Failed host lookup',
        'No address associated', 'errno = 7', 'OSError'
      ].any((s) => errorString.contains(s));

      final userFriendlyMsg = hasConnError
          ? "No internet connection. Please check your network and try again."
          : "Something went wrong. Please try again.";

      errorMessage.value = userFriendlyMsg;

      Get.snackbar(
        'Match Analysis Failed',
        userFriendlyMsg,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAnalyzing.value = false;
    }
  }
}
