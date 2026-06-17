import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/job_match_result_model.dart';

class JobMatchService {
  // Placeholder API Key. Replace with your actual Gemini API Key.
  static const String _geminiApiKey = 'YOUR_API_KEY';

  static Future<JobMatchResultModel> matchResumeToJD(String resumeText, String jobDescription) async {
    if (_geminiApiKey == 'YOUR_API_KEY' || _geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not set. Please update lib/services/job_match_service.dart');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
    );

    final prompt = '''
You are an expert recruiter and ATS specialist. Compare the resume and job
description provided and return ONLY a valid JSON object with no markdown, no
backticks, and no extra text. The JSON must follow this exact structure:
{
  "matchScore": <int 0-100>,
  "matchedKeywords": ["<keyword1>", "<keyword2>", ...],
  "missingKeywords": ["<keyword1>", "<keyword2>", ...],
  "roleFitSummary": "<2-3 sentence summary of how well the candidate fits the role>"
}

RESUME:
$resumeText

JOB DESCRIPTION:
$jobDescription
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      throw Exception('Failed to get a response from Gemini.');
    }

    try {
      // Clean JSON formatting
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      final int matchScore = data['matchScore'] ?? 0;
      final List<dynamic> matchedKeywordsRaw = data['matchedKeywords'] ?? [];
      final List<dynamic> missingKeywordsRaw = data['missingKeywords'] ?? [];
      final String roleFitSummary = data['roleFitSummary'] ?? '';

      final List<String> matchedKeywords = matchedKeywordsRaw.map((e) => e.toString()).toList();
      final List<String> missingKeywords = missingKeywordsRaw.map((e) => e.toString()).toList();

      final String snippet = jobDescription.length > 100
          ? '${jobDescription.substring(0, 100)}...'
          : jobDescription;

      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      return JobMatchResultModel(
        id: id,
        analyzedAt: DateTime.now(),
        matchScore: matchScore,
        matchedKeywords: matchedKeywords,
        missingKeywords: missingKeywords,
        roleFitSummary: roleFitSummary,
        jobDescriptionSnippet: snippet,
      );
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
  }
}
