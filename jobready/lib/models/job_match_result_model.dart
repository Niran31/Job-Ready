import 'package:hive/hive.dart';

part 'job_match_result_model.g.dart';

@HiveType(typeId: 5)
class JobMatchResultModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime analyzedAt;

  @HiveField(2)
  final int matchScore;

  @HiveField(3)
  final List<String> matchedKeywords;

  @HiveField(4)
  final List<String> missingKeywords;

  @HiveField(5)
  final String roleFitSummary;

  @HiveField(6)
  final String jobDescriptionSnippet;

  JobMatchResultModel({
    required this.id,
    required this.analyzedAt,
    required this.matchScore,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.roleFitSummary,
    required this.jobDescriptionSnippet,
  });
}
