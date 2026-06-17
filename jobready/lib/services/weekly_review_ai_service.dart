import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class WeeklyReviewAiService {
  // Configured with the API Key you provided.
  static const String _geminiApiKey = 'YOUR_API_KEY';

  static Future<Map<String, dynamic>> generateReview(Map<String, dynamic> weekData) async {
    if (_geminiApiKey == 'YOUR_API_KEY' || _geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key is not set. Please update lib/services/weekly_review_ai_service.dart');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
    );

    final userMessage = '''
Weekly Stats:
- Job applications sent: ${weekData['applicationsSent']}
- Weekly target applications: ${weekData['targetApplications']}
- Skill hours logged: ${weekData['skillHours']}
- Weekly target skill hours: ${weekData['targetSkillHours']}
- Habits completed: ${weekData['habitsCompleted']}
- Total habits tracked: ${weekData['totalHabits']}
- Coding sessions: ${weekData['codingSessions']}
- Interviews received: ${weekData['interviewsReceived']}
- Week ending date: ${weekData['weekEndDate']}
''';

    final prompt = '''
You are a career coach and productivity expert. Based on the user's weekly
activity data provided, generate a weekly review. Return ONLY a valid JSON
object with no markdown, no backticks, and no extra text:
{
  "grade": "<A/B/C/D/F>",
  "strengths": "<2-3 sentences about what went well>",
  "weaknesses": "<2-3 sentences about what needs improvement>",
  "reflection": "<motivational 2-3 sentence closing reflection>",
  "suggestion": "<one specific actionable tip for next week>"
}

$userMessage
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
      
      return {
        'grade': data['grade'] ?? 'C',
        'strengths': data['strengths'] ?? '',
        'weaknesses': data['weaknesses'] ?? '',
        'reflection': data['reflection'] ?? '',
        'suggestion': data['suggestion'] ?? '',
      };
    } catch (e) {
      throw Exception('Failed to parse Gemini weekly review response: $e');
    }
  }
}
