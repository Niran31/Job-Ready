import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String emoji;

  @HiveField(2)
  List<String> completedDates; // stored as "yyyy-MM-dd" strings

  @HiveField(3)
  String category; // 'skill', 'job', 'health', 'general'

  HabitModel({
    required this.name,
    required this.emoji,
    required this.category,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool isCompletedToday() {
    final today = _dateKey(DateTime.now());
    return completedDates.contains(today);
  }

  void toggleToday() {
    final today = _dateKey(DateTime.now());
    if (completedDates.contains(today)) {
      completedDates.remove(today);
    } else {
      completedDates.add(today);
    }
    save();
  }

  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final key = _dateKey(day);
      if (completedDates.contains(key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─── Job Application Model ─────────────────────────────────────────────────

@HiveType(typeId: 1)
class JobModel extends HiveObject {
  @HiveField(0)
  String company;

  @HiveField(1)
  String role;

  @HiveField(2)
  String status; // 'applied', 'interview', 'offer', 'rejected', 'ghosted'

  @HiveField(3)
  String appliedDate;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  String? jobUrl;

  JobModel({
    required this.company,
    required this.role,
    required this.status,
    required this.appliedDate,
    this.notes,
    this.jobUrl,
  });
}

// ─── Skill Log Model ───────────────────────────────────────────────────────

@HiveType(typeId: 2)
class SkillLogModel extends HiveObject {
  @HiveField(0)
  String skill; // e.g. "Flutter", "DSA", "ML"

  @HiveField(1)
  double hoursStudied;

  @HiveField(2)
  String date; // "yyyy-MM-dd"

  @HiveField(3)
  String? notes;

  SkillLogModel({
    required this.skill,
    required this.hoursStudied,
    required this.date,
    this.notes,
  });
}

// ─── Weekly Review Model ───────────────────────────────────────────────────

@HiveType(typeId: 3)
class WeeklyReviewModel extends HiveObject {
  @HiveField(0)
  String weekEndDate; // "yyyy-MM-dd"

  @HiveField(1)
  String grade; // 'A', 'B', 'C', 'D'

  @HiveField(2)
  int applicationsSent;

  @HiveField(3)
  int interviewsReceived;

  @HiveField(4)
  double skillHoursCompleted;

  @HiveField(5)
  double habitCompletionRate;

  @HiveField(6)
  int grindScoreChange;

  @HiveField(7)
  String reflectionNotes;

  @HiveField(8)
  List<String> strengths;

  @HiveField(9)
  List<String> weaknesses;

  WeeklyReviewModel({
    required this.weekEndDate,
    required this.grade,
    required this.applicationsSent,
    required this.interviewsReceived,
    required this.skillHoursCompleted,
    required this.habitCompletionRate,
    required this.grindScoreChange,
    required this.reflectionNotes,
    required this.strengths,
    required this.weaknesses,
  });
}
