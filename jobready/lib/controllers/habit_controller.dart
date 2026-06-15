import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';
import '../services/github_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import 'notification_controller.dart';

class HabitController extends GetxController {
  late Box<HabitModel> _habitBox;
  late Box<JobModel> _jobBox;
  late Box<SkillLogModel> _skillBox;
  late Box<WeeklyReviewModel> _reviewBox;

  final RxList<HabitModel> habits = <HabitModel>[].obs;
  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxList<SkillLogModel> skillLogs = <SkillLogModel>[].obs;
  final RxList<WeeklyReviewModel> weeklyReviews = <WeeklyReviewModel>[].obs;

  // Career Targets
  final RxInt targetJobs = 25.obs;
  final RxDouble targetHours = 15.0.obs;
  final RxInt targetCoding = 5.obs;
  final RxInt targetDsa = 3.obs;

  // GitHub Auto-Tracker
  final RxString githubUsername = ''.obs;
  final RxBool enableGithubTracking = false.obs;
  final RxBool isGithubSyncing = false.obs;

  // Days since June 22
  final int unemployedDay = _calcDaysSinceJune22();

  static int _calcDaysSinceJune22() {
    final start = DateTime(2026, 6, 22);
    final now = DateTime.now();
    if (now.isBefore(start)) return 0;
    return now.difference(start).inDays + 1;
  }

  @override
  void onInit() {
    super.onInit();
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    await _loadTargets();
    _habitBox = Hive.box<HabitModel>('habits');
    _jobBox = Hive.box<JobModel>('jobs');
    _skillBox = Hive.box<SkillLogModel>('skills');
    _reviewBox = Hive.box<WeeklyReviewModel>('weekly_reviews');
    _loadData();
    _seedDefaultHabitsIfEmpty();
    checkGitHubCommits();
    _refreshStreakNotification();
  }

  Future<void> _loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    targetJobs.value = prefs.getInt('targetJobs') ?? 25;
    targetHours.value = prefs.getDouble('targetHours') ?? 15.0;
    targetCoding.value = prefs.getInt('targetCoding') ?? 5;
    targetDsa.value = prefs.getInt('targetDsa') ?? 3;
    githubUsername.value = prefs.getString('githubUsername') ?? '';
    enableGithubTracking.value = prefs.getBool('enableGithubTracking') ?? false;
  }

  Future<void> updateGitHubSettings(String username, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    githubUsername.value = username;
    enableGithubTracking.value = enabled;
    await prefs.setString('githubUsername', username);
    await prefs.setBool('enableGithubTracking', enabled);

    if (enabled && username.isNotEmpty) {
      checkGitHubCommits();
    }
  }

  Future<void> checkGitHubCommits() async {
    if (githubUsername.value.isEmpty || !enableGithubTracking.value) return;

    isGithubSyncing.value = true;
    try {
      final committed = await GitHubService.hasCommittedToday(githubUsername.value);
      if (committed) {
        final codingHabit = habits.firstWhereOrNull((h) {
          final name = h.name.toLowerCase();
          return name.contains('code') || name.contains('build');
        });

        if (codingHabit != null) {
          final today = _todayKey();
          if (!codingHabit.completedDates.contains(today)) {
            codingHabit.completedDates.add(today);
            codingHabit.save();
            habits.refresh();
            await NotificationService.showMotivation(
                'GitHub activity detected! Coding habit checked off auto-magically 💻🔥');
            
            _syncSingle('habits', codingHabit.name, {
              'name': codingHabit.name,
              'emoji': codingHabit.emoji,
              'category': codingHabit.category,
              'completedDates': codingHabit.completedDates,
            });
          }
        }
      }
    } finally {
      isGithubSyncing.value = false;
    }
  }

  Future<void> updateTargets({int? jobsVal, double? hoursVal, int? codingVal, int? dsaVal}) async {
    final prefs = await SharedPreferences.getInstance();
    if (jobsVal != null) {
      targetJobs.value = jobsVal;
      await prefs.setInt('targetJobs', jobsVal);
    }
    if (hoursVal != null) {
      targetHours.value = hoursVal;
      await prefs.setDouble('targetHours', hoursVal);
    }
    if (codingVal != null) {
      targetCoding.value = codingVal;
      await prefs.setInt('targetCoding', codingVal);
    }
    if (dsaVal != null) {
      targetDsa.value = dsaVal;
      await prefs.setInt('targetDsa', dsaVal);
    }
  }

  void _loadData() {
    habits.value = _habitBox.values.toList();
    jobs.value = _jobBox.values.toList();
    skillLogs.value = _skillBox.values.toList();
    weeklyReviews.value = _reviewBox.values.toList();
  }

  void loadDataFromBoxes() {
    _loadData();
  }

  void _seedDefaultHabitsIfEmpty() {
    if (_habitBox.isEmpty) {
      final defaults = [
        HabitModel(name: 'Code / build', emoji: '💻', category: 'skill'),
        HabitModel(name: 'Apply for jobs', emoji: '📨', category: 'job'),
        HabitModel(name: 'LeetCode / DSA', emoji: '🧠', category: 'skill'),
        HabitModel(name: 'Wake up before 9 AM', emoji: '☀️', category: 'health'),
        HabitModel(name: 'No doomscrolling before noon', emoji: '📵', category: 'health'),
      ];
      for (final h in defaults) {
        _habitBox.add(h);
      }
      habits.value = _habitBox.values.toList();
    }
  }

  void toggleHabit(HabitModel habit) {
    habit.toggleToday();
    habits.refresh();
    _syncSingle('habits', habit.name, {
      'name': habit.name,
      'emoji': habit.emoji,
      'category': habit.category,
      'completedDates': habit.completedDates,
    });
    _refreshStreakNotification();
  }

  void addHabit(String name, String emoji, String category) {
    final h = HabitModel(name: name, emoji: emoji, category: category);
    _habitBox.add(h);
    habits.value = _habitBox.values.toList();
    _syncSingle('habits', name, {
      'name': name,
      'emoji': emoji,
      'category': category,
      'completedDates': [],
    });
    _refreshStreakNotification();
  }

  void deleteHabit(HabitModel habit) {
    final name = habit.name;
    habit.delete();
    habits.value = _habitBox.values.toList();
    _deleteSingle('habits', name);
    _refreshStreakNotification();
  }

  // ── Jobs ──────────────────────────────────────────────────────────────────

  void addJob(String company, String role, {String? url, String? notes}) {
    final today = _todayKey();
    final j = JobModel(
      company: company,
      role: role,
      status: 'applied',
      appliedDate: today,
      jobUrl: url,
      notes: notes,
    );
    _jobBox.add(j);
    jobs.value = _jobBox.values.toList();
    _syncSingle('jobs', '${company}_${role}_${today}', {
      'company': company,
      'role': role,
      'status': 'applied',
      'appliedDate': today,
      'jobUrl': url,
      'notes': notes,
    });
  }

  void updateJobStatus(JobModel job, String status) {
    job.status = status;
    job.save();
    jobs.refresh();
    _syncSingle('jobs', '${job.company}_${job.role}_${job.appliedDate}', {
      'company': job.company,
      'role': job.role,
      'status': status,
      'appliedDate': job.appliedDate,
      'jobUrl': job.jobUrl,
      'notes': job.notes,
    });
  }

  void deleteJob(JobModel job) {
    final docId = '${job.company}_${job.role}_${job.appliedDate}';
    job.delete();
    jobs.value = _jobBox.values.toList();
    _deleteSingle('jobs', docId);
  }

  // ── Skills ────────────────────────────────────────────────────────────────

  void logSkill(String skill, double hours, {String? notes}) {
    final today = _todayKey();
    final log = SkillLogModel(
      skill: skill,
      hoursStudied: hours,
      date: today,
      notes: notes,
    );
    _skillBox.add(log);
    skillLogs.value = _skillBox.values.toList();
    _syncSingle('skills', '${skill}_${today}_${hours}', {
      'skill': skill,
      'hoursStudied': hours,
      'date': today,
      'notes': notes,
    });
  }

  // ── Outcome Stats ─────────────────────────────────────────────────────────

  int get todayCompletedCount =>
      habits.where((h) => h.isCompletedToday()).length;

  int get totalJobsApplied => jobs.length;

  int get activeApplications =>
      jobs.where((j) => j.status == 'applied' || j.status == 'interview').length;

  int get totalInterviewsScheduled =>
      jobs.where((j) => j.status == 'interview').length;

  DateTime startOfWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  }

  int get weeklyJobsApplied {
    final start = startOfWeek();
    return jobs.where((j) {
      final date = DateTime.tryParse(j.appliedDate);
      if (date == null) return false;
      return !date.isBefore(start);
    }).length;
  }

  double get weeklySkillHours {
    final start = startOfWeek();
    return skillLogs.where((s) {
      final date = DateTime.tryParse(s.date);
      if (date == null) return false;
      return !date.isBefore(start);
    }).fold(0.0, (sum, s) => sum + s.hoursStudied);
  }

  double get totalSkillHoursThisWeek {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return skillLogs
        .where((s) => DateTime.tryParse(s.date)?.isAfter(weekAgo) ?? false)
        .fold(0.0, (sum, s) => sum + s.hoursStudied);
  }

  int get longestCurrentStreak {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  // ── Employment Status ──────────────────────────────────────────────────────

  String get employmentStatus {
    if (jobs.any((j) => j.status == 'offer')) {
      return 'Employed Mode';
    }
    final end = DateTime(2026, 6, 22);
    final now = DateTime.now();
    if (now.isBefore(end)) {
      return 'Internship Mode';
    } else {
      return 'Job Hunt Mode';
    }
  }

  int get daysInStatus {
    final end = DateTime(2026, 6, 22);
    final now = DateTime.now();
    if (employmentStatus == 'Employed Mode') {
      final offerJob = jobs.firstWhereOrNull((j) => j.status == 'offer');
      if (offerJob != null) {
        final offerDate = DateTime.tryParse(offerJob.appliedDate) ?? now;
        return now.difference(offerDate).inDays + 1;
      }
      return 0;
    } else if (employmentStatus == 'Internship Mode') {
      return end.difference(now).inDays + 1;
    } else {
      return now.difference(end).inDays + 1;
    }
  }

  // ── Grind Score ────────────────────────────────────────────────────────────

  int get grindScore {
    int score = 0;
    for (final j in jobs) {
      if (j.status == 'interview') {
        score += 30; // 5 (app) + 25 (interview)
      } else if (j.status == 'offer') {
        score += 105; // 5 (app) + 100 (offer)
      } else {
        score += 5; // applied, rejected, ghosted
      }
    }
    for (final s in skillLogs) {
      score += (s.hoursStudied * 2).toInt();
      if (s.skill == 'DSA') score += 5;
      if (['flutter', 'dart', 'react', 'python', 'system design', 'fastapi', 'flask', 'sql', 'ml / ai']
          .contains(s.skill.toLowerCase())) {
        score += 10;
      }
    }
    for (final h in habits) {
      final nameLower = h.name.toLowerCase();
      final isDsa = nameLower.contains('dsa') || nameLower.contains('leetcode');
      final isProject = nameLower.contains('code') || nameLower.contains('build');
      for (final _ in h.completedDates) {
        score += 1;
        if (isDsa) score += 5;
        if (isProject) score += 10;
      }
    }
    return score;
  }

  String get grindRank {
    final s = grindScore;
    if (s > 1000) return 'Career Beast';
    if (s > 600) return 'Grinder';
    if (s > 300) return 'Builder';
    if (s > 100) return 'Momentum';
    return 'Getting Started';
  }

  int getGrindScoreOnDate(DateTime date) {
    int score = 0;
    final normalizedDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    for (final j in jobs) {
      final appDate = DateTime.tryParse(j.appliedDate);
      if (appDate != null && !appDate.isAfter(normalizedDate)) {
        if (j.status == 'interview') {
          score += 30;
        } else if (j.status == 'offer') {
          score += 105;
        } else {
          score += 5;
        }
      }
    }

    for (final s in skillLogs) {
      final sDate = DateTime.tryParse(s.date);
      if (sDate != null && !sDate.isAfter(normalizedDate)) {
        score += (s.hoursStudied * 2).toInt();
        if (s.skill == 'DSA') score += 5;
        if (['flutter', 'dart', 'react', 'python', 'system design', 'fastapi', 'flask', 'sql', 'ml / ai']
            .contains(s.skill.toLowerCase())) {
          score += 10;
        }
      }
    }

    for (final h in habits) {
      final nameLower = h.name.toLowerCase();
      final isDsa = nameLower.contains('dsa') || nameLower.contains('leetcode');
      final isProject = nameLower.contains('code') || nameLower.contains('build');
      for (final d in h.completedDates) {
        final compDate = DateTime.tryParse(d);
        if (compDate != null && !compDate.isAfter(normalizedDate)) {
          score += 1;
          if (isDsa) score += 5;
          if (isProject) score += 10;
        }
      }
    }

    return score;
  }

  int get weeklyGrindScoreEarned {
    final start = startOfWeek();
    int score = 0;
    for (final j in jobs) {
      final date = DateTime.tryParse(j.appliedDate);
      if (date == null || date.isBefore(start)) continue;
      if (j.status == 'interview') {
        score += 30;
      } else if (j.status == 'offer') {
        score += 105;
      } else {
        score += 5;
      }
    }
    for (final s in skillLogs) {
      final date = DateTime.tryParse(s.date);
      if (date == null || date.isBefore(start)) continue;
      score += (s.hoursStudied * 2).toInt();
      if (s.skill == 'DSA') score += 5;
      if (['flutter', 'dart', 'react', 'python', 'system design', 'fastapi', 'flask', 'sql', 'ml / ai']
          .contains(s.skill.toLowerCase())) {
        score += 10;
      }
    }
    for (final h in habits) {
      final nameLower = h.name.toLowerCase();
      final isDsa = nameLower.contains('dsa') || nameLower.contains('leetcode');
      final isProject = nameLower.contains('code') || nameLower.contains('build');
      for (final d in h.completedDates) {
        final date = DateTime.tryParse(d);
        if (date == null || date.isBefore(start)) continue;
        score += 1;
        if (isDsa) score += 5;
        if (isProject) score += 10;
      }
    }
    return score;
  }

  // ── No Zero Day System ─────────────────────────────────────────────────────

  bool checkActivityForDay(DateTime day) {
    final key = _dateKey(day);
    final hasJob = jobs.any((j) => j.appliedDate == key);
    if (hasJob) return true;

    final hours = skillLogs.where((s) => s.date == key).fold(0.0, (sum, s) => sum + s.hoursStudied);
    if (hours >= 0.5) return true;

    final hasCoding = habits.any((h) =>
        (h.name.toLowerCase().contains('code') || h.name.toLowerCase().contains('build')) &&
        h.completedDates.contains(key));
    if (hasCoding) return true;

    final hasDsa = habits.any((h) =>
        (h.name.toLowerCase().contains('dsa') || h.name.toLowerCase().contains('leetcode')) &&
        h.completedDates.contains(key));
    if (hasDsa) return true;

    return false;
  }

  int get noZeroDayStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    bool todayActive = checkActivityForDay(day);
    if (todayActive) {
      streak = 1;
      day = day.subtract(const Duration(days: 1));
      while (checkActivityForDay(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      }
    } else {
      DateTime yesterday = day.subtract(const Duration(days: 1));
      if (checkActivityForDay(yesterday)) {
        streak = 1;
        yesterday = yesterday.subtract(const Duration(days: 1));
        while (checkActivityForDay(yesterday)) {
          streak++;
          yesterday = yesterday.subtract(const Duration(days: 1));
        }
      } else {
        streak = 0;
      }
    }
    return streak;
  }

  bool isZeroDay(DateTime day) {
    return !checkActivityForDay(day);
  }

  // ── Weekly Target Progress ─────────────────────────────────────────────────

  int get weeklyCodingSessions {
    final start = startOfWeek();
    final dates = <String>{};
    for (final h in habits) {
      if (h.name.toLowerCase().contains('code') || h.name.toLowerCase().contains('build')) {
        for (final d in h.completedDates) {
          final date = DateTime.tryParse(d);
          if (date != null && !date.isBefore(start)) {
            dates.add(d);
          }
        }
      }
    }
    return dates.length;
  }

  int get weeklyDsaSessions {
    final start = startOfWeek();
    final dates = <String>{};
    for (final h in habits) {
      if (h.name.toLowerCase().contains('dsa') || h.name.toLowerCase().contains('leetcode')) {
        for (final d in h.completedDates) {
          final date = DateTime.tryParse(d);
          if (date != null && !date.isBefore(start)) {
            dates.add(d);
          }
        }
      }
    }
    return dates.length;
  }

  String get targetPaceStatus {
    final dayOfWeek = DateTime.now().weekday;
    final elapsedPace = dayOfWeek / 7.0;

    final jobsProgress = targetJobs.value == 0 ? 1.0 : weeklyJobsApplied / targetJobs.value;
    final hoursProgress = targetHours.value == 0.0 ? 1.0 : weeklySkillHours / targetHours.value;
    final averageProgress = (jobsProgress + hoursProgress) / 2.0;

    final diff = averageProgress - elapsedPace;
    if (diff >= 0.1) return 'Ahead';
    if (diff < -0.1) return 'Behind';
    return 'On Track';
  }

  // ── Projections ────────────────────────────────────────────────────────────

  double get monthlyAppPace {
    if (jobs.isEmpty) return 0.0;
    final dates = jobs.map((j) => DateTime.tryParse(j.appliedDate)).whereType<DateTime>().toList();
    if (dates.isEmpty) return 0.0;
    final firstDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final days = DateTime.now().difference(firstDate).inDays.clamp(1, 30);
    return (jobs.length / days) * 30;
  }

  double get monthlySkillPace {
    if (skillLogs.isEmpty) return 0.0;
    final dates = skillLogs.map((s) => DateTime.tryParse(s.date)).whereType<DateTime>().toList();
    if (dates.isEmpty) return 0.0;
    final firstDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final days = DateTime.now().difference(firstDate).inDays.clamp(1, 30);
    final totalHours = skillLogs.fold(0.0, (sum, s) => sum + s.hoursStudied);
    return (totalHours / days) * 30;
  }

  double get interviewConversionRate {
    if (jobs.isEmpty) return 0.0;
    final interviews = jobs.where((j) => j.status == 'interview').length;
    return (interviews / jobs.length) * 100;
  }

  double get expectedInterviewsPerMonth {
    final rate = interviewConversionRate / 100;
    final finalRate = rate == 0.0 ? 0.10 : rate;
    return monthlyAppPace * finalRate;
  }

  // ── Weekly Career Review ───────────────────────────────────────────────────

  DateTime getLastSunday() {
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday) {
      return now;
    } else {
      return now.subtract(Duration(days: now.weekday));
    }
  }

  String get lastSundayKey => _dateKey(getLastSunday());

  bool get isWeeklyReviewDue {
    return !weeklyReviews.any((r) => r.weekEndDate == lastSundayKey);
  }

  double get weeklyHabitCompletionRate {
    if (habits.isEmpty) return 0.0;
    final start = startOfWeek();
    int completedCount = 0;
    int totalPossible = 0;
    final today = DateTime.now();
    final elapsedDays = today.difference(start).inDays + 1;

    for (final h in habits) {
      for (final d in h.completedDates) {
        final date = DateTime.tryParse(d);
        if (date != null && !date.isBefore(start) && !date.isAfter(today)) {
          completedCount++;
        }
      }
      totalPossible += elapsedDays;
    }
    return totalPossible == 0 ? 0.0 : completedCount / totalPossible;
  }

  void saveWeeklyReview(String reflection, String gradeVal, List<String> strengthsList, List<String> weaknessesList) {
    final key = lastSundayKey;
    final appsCount = weeklyJobsApplied;
    final interviewsCount = jobs.where((j) {
      final date = DateTime.tryParse(j.appliedDate);
      if (date == null || date.isBefore(startOfWeek())) return false;
      return j.status == 'interview';
    }).length;
    final hoursCount = weeklySkillHours;
    final habitRate = weeklyHabitCompletionRate;
    final scoreChange = weeklyGrindScoreEarned;

    final review = WeeklyReviewModel(
      weekEndDate: key,
      grade: gradeVal,
      applicationsSent: appsCount,
      interviewsReceived: interviewsCount,
      skillHoursCompleted: hoursCount,
      habitCompletionRate: habitRate,
      grindScoreChange: scoreChange,
      reflectionNotes: reflection,
      strengths: strengthsList,
      weaknesses: weaknessesList,
    );
    _reviewBox.put(key, review);
    weeklyReviews.value = _reviewBox.values.toList();

    _syncSingle('weekly_reviews', key, {
      'weekEndDate': key,
      'grade': gradeVal,
      'applicationsSent': appsCount,
      'interviewsReceived': interviewsCount,
      'skillHoursCompleted': hoursCount,
      'habitCompletionRate': habitRate,
      'grindScoreChange': scoreChange,
      'reflectionNotes': reflection,
      'strengths': strengthsList,
      'weaknesses': weaknessesList,
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _todayKey() => _dateKey(DateTime.now());

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _syncSingle(String collectionName, String docId, Map<String, dynamic> data) {
    if (Get.isRegistered<SyncService>()) {
      Get.find<SyncService>().syncSingleRecord(
        collectionName: collectionName,
        docId: docId,
        data: data,
      );
    }
  }

  void _deleteSingle(String collectionName, String docId) {
    if (Get.isRegistered<SyncService>()) {
      Get.find<SyncService>().deleteSingleRecord(
        collectionName: collectionName,
        docId: docId,
      );
    }
  }

  void _refreshStreakNotification() {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshStreakNotification(longestCurrentStreak);
    }
  }
}
