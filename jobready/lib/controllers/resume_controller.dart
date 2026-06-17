import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:hive/hive.dart';
import '../models/resume_result_model.dart';
import '../services/resume_ai_service.dart';

class ResumeController extends GetxController {
  final RxString inputMode = 'paste'.obs; // 'paste' or 'pdf'
  final RxString resumeText = ''.obs;
  final RxBool isAnalyzing = false.obs;
  final Rx<ResumeResultModel?> result = Rx<ResumeResultModel?>(null);
  final RxString errorMessage = ''.obs;
  
  // For UI display of picked file name
  final RxString pickedFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load last result from Hive if available
    _loadLastResult();
  }

  void _loadLastResult() {
    try {
      final box = Hive.box<ResumeResultModel>('resume_results');
      if (box.isNotEmpty) {
        // Sort by analyzedAt descending
        final results = box.values.toList()
          ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
        result.value = results.first;
      }
    } catch (e) {
      debugPrint('Error loading past resume results: $e');
    }
  }

  void toggleInputMode(String mode) {
    inputMode.value = mode;
    errorMessage.value = '';
    
    // Clear state when switching modes
    if (mode == 'paste') {
      pickedFileName.value = '';
    }
  }

  Future<void> pickPdf() async {
    try {
      errorMessage.value = '';
      
      FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (fileResult != null) {
        PlatformFile file = fileResult.files.first;
        pickedFileName.value = file.name;

        if (kIsWeb) {
          // read_pdf_text might not support web fully, handle gracefully if so
          // For now, web pdf parsing might be limited depending on the package
          errorMessage.value = 'PDF parsing on Web might be limited.';
        } else {
          if (file.path != null) {
            String text = await ReadPdfText.getPDFtext(file.path!) ?? '';
            if (text.trim().isEmpty) {
              errorMessage.value = 'Could not extract text from this PDF. It might be scanned or image-based.';
            } else {
              resumeText.value = text;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      errorMessage.value = 'Failed to pick or read PDF file.';
    }
  }

  Future<void> analyze() async {
    if (resumeText.value.trim().isEmpty) {
      errorMessage.value = 'Please provide resume text or upload a valid PDF.';
      return;
    }

    try {
      isAnalyzing.value = true;
      errorMessage.value = '';
      
      final generatedResult = await ResumeAiService.analyzeResume(resumeText.value);
      
      // Save to Hive
      final box = Hive.box<ResumeResultModel>('resume_results');
      await box.put(generatedResult.id, generatedResult);
      
      result.value = generatedResult;
      
    } catch (e) {
      debugPrint('Analyze Error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      Get.snackbar(
        'Analysis Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAnalyzing.value = false;
    }
  }
}
