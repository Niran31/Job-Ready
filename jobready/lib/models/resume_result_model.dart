import 'package:hive/hive.dart';

part 'resume_result_model.g.dart';

@HiveType(typeId: 4)
class ResumeResultModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime analyzedAt;

  @HiveField(2)
  int overallScore;

  @HiveField(3)
  int atsScore;

  @HiveField(4)
  String sectionFeedback;

  @HiveField(5)
  List<String> keywordGaps;

  @HiveField(6)
  String resumeTextSnippet;

  ResumeResultModel({
    required this.id,
    required this.analyzedAt,
    required this.overallScore,
    required this.atsScore,
    required this.sectionFeedback,
    required this.keywordGaps,
    required this.resumeTextSnippet,
  });
}
