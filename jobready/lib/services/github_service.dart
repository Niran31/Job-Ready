import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  /// Queries public GitHub events for [username] and checks if they committed today.
  static Future<bool> hasCommittedToday(String username) async {
    if (username.trim().isEmpty) return false;

    try {
      final url = Uri.parse('https://api.github.com/users/${username.trim()}/events/public');
      // Set User-Agent to avoid getting blocked by GitHub API
      final response = await http.get(
        url,
        headers: {'User-Agent': 'JobReady-Flutter-App'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);
        final todayStr = _todayString();

        for (var event in events) {
          final type = event['type'];
          final createdAt = event['created_at']; // UTC string e.g. "2026-06-11T09:44:07Z"

          if (type == 'PushEvent' && createdAt != null) {
            final eventDateTime = DateTime.tryParse(createdAt)?.toLocal();
            if (eventDateTime != null) {
              final eventDateStr =
                  '${eventDateTime.year}-${eventDateTime.month.toString().padLeft(2, '0')}-${eventDateTime.day.toString().padLeft(2, '0')}';
              if (eventDateStr == todayStr) {
                return true;
              }
            }
          }
        }
      }
    } catch (e) {
      // Silent catch or debug log
      print('GitHub API query failed: $e');
    }
    return false;
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
