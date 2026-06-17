import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class InterviewService {
  // Placeholder API Key. Replace with your actual Gemini API Key.
  static const String _geminiApiKey = 'YOUR_API_KEY';

  static Future<List<String>> generateQuestions(String resumeText, String jobDescription) async {
    if (_geminiApiKey == 'YOUR_API_KEY' || _geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not set. Please update lib/services/interview_service.dart');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
    );

    final prompt = '''
You are an expert technical interviewer. Based on the resume and job description
provided, generate exactly 8 interview questions: 4 HR/behavioral and 4 technical.
Return ONLY a valid JSON array of strings with no markdown, no backticks, and no
extra text. Example format:
["Question 1", "Question 2", ..., "Question 8"]

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

      final List<dynamic> rawList = jsonDecode(cleanJson);
      final List<String> questions = rawList.map((e) => e.toString()).toList();
      
      if (questions.length != 8) {
        throw Exception('Expected exactly 8 questions, but got ${questions.length}');
      }
      
      return questions;
    } catch (e) {
      throw Exception('Failed to parse Gemini questions response: $e');
    }
  }

  static Future<Map<String, dynamic>> evaluateAnswers(List<String> questions, List<String> answers) async {
    if (_geminiApiKey == 'YOUR_API_KEY' || _geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not set. Please update lib/services/interview_service.dart');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
    );

    final userPayload = jsonEncode({
      'questions': questions,
      'answers': answers,
    });

    final prompt = '''
You are an expert interview coach. Evaluate each answer to the interview question
provided. Return ONLY a valid JSON object with no markdown, no backticks, and no
extra text. The JSON must follow this exact structure:
{
  "answerScores": [<int 0-10>, ...],
  "answerFeedback": ["<tip for answer 1>", ...],
  "overallScore": <int 0-100>,
  "overallSummary": "<2-3 sentence overall performance summary>"
}

USER MESSAGE:
$userPayload
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      throw Exception('Failed to get a response from Gemini.');
    }

    try {
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

      // Validate structure keys
      final List<dynamic> answerScoresRaw = data['answerScores'] ?? [];
      final List<dynamic> answerFeedbackRaw = data['answerFeedback'] ?? [];
      final int overallScore = data['overallScore'] ?? 0;
      final String overallSummary = data['overallSummary'] ?? '';

      final List<int> answerScores = answerScoresRaw.map((e) => int.parse(e.toString())).toList();
      final List<String> answerFeedback = answerFeedbackRaw.map((e) => e.toString()).toList();

      return {
        'answerScores': answerScores,
        'answerFeedback': answerFeedback,
        'overallScore': overallScore,
        'overallSummary': overallSummary,
      };
    } catch (e) {
      throw Exception('Failed to parse Gemini evaluation response: $e');
    }
  }
}
