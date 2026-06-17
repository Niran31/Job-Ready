import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/resume_result_model.dart';

class ResumeAiService {
  // Placeholder API Key. Replace with your actual Gemini API Key.
  static const String _geminiApiKey = 'YOUR_API_KEY';

  static Future<ResumeResultModel> analyzeResume(String resumeText) async {
    if (_geminiApiKey == 'YOUR_API_KEY' || _geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not set. Please update lib/services/resume_ai_service.dart');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'YOUR_API_KEY',
    );

    final prompt = '''
You are a professional resume reviewer and ATS expert. Analyze the resume text
provided and return ONLY a valid JSON object with no markdown, no backticks, and
no extra text. The JSON must follow this exact structure:
{
  "overallScore": <int 0-100>,
  "atsScore": <int 0-100>,
  "sectionFeedback": {
    "summary": "<feedback string>",
    "skills": "<feedback string>",
    "experience": "<feedback string>",
    "education": "<feedback string>"
  },
  "keywordGaps": ["<keyword1>", "<keyword2>"]
}

Resume Text:
$resumeText
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      throw Exception('Failed to get a response from Gemini.');
    }

    // Attempt to parse JSON securely
    try {
      // Sometimes Gemini wraps JSON in backticks even if told not to
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
      
      // Ensure all keys exist
      final int overallScore = data['overallScore'] ?? 0;
      final int atsScore = data['atsScore'] ?? 0;
      final Map<String, dynamic> sectionFeedbackMap = data['sectionFeedback'] ?? {};
      final List<dynamic> keywordGapsRaw = data['keywordGaps'] ?? [];
      
      final List<String> keywordGaps = keywordGapsRaw.map((e) => e.toString()).toList();
      final String sectionFeedback = jsonEncode(sectionFeedbackMap); // Store as JSON string in Hive
      
      // Generate a simple ID
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create a small snippet
      final String snippet = resumeText.length > 200 
          ? '${resumeText.substring(0, 200)}...' 
          : resumeText;

      return ResumeResultModel(
        id: id,
        analyzedAt: DateTime.now(),
        overallScore: overallScore,
        atsScore: atsScore,
        sectionFeedback: sectionFeedback,
        keywordGaps: keywordGaps,
        resumeTextSnippet: snippet,
      );
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
  }
}
