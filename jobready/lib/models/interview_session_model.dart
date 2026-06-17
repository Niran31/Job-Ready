import 'package:hive/hive.dart';

part 'interview_session_model.g.dart';

@HiveType(typeId: 6)
class InterviewSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime sessionDate;

  @HiveField(2)
  final String jobDescriptionSnippet;

  @HiveField(3)
  final List<String> questions;

  @HiveField(4)
  final List<String> userAnswers;

  @HiveField(5)
  final List<int> answerScores;

  @HiveField(6)
  final List<String> answerFeedback;

  @HiveField(7)
  final int overallScore;

  @HiveField(8)
  final String overallSummary;

  InterviewSessionModel({
    required this.id,
    required this.sessionDate,
    required this.jobDescriptionSnippet,
    required this.questions,
    required this.userAnswers,
    required this.answerScores,
    required this.answerFeedback,
    required this.overallScore,
    required this.overallSummary,
  });
}
