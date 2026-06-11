import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../controllers/habit_controller.dart';

class SyncService extends GetxService {
  static SyncService get to => Get.find();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isSyncing = false.obs;
  final RxBool isFirebaseAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkFirebaseAvailability();
  }

  void _checkFirebaseAvailability() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      isFirebaseAvailable.value = true;
      currentUser.value = _auth!.currentUser;
      _auth!.authStateChanges().listen((user) {
        currentUser.value = user;
        if (user != null) {
          syncAll(user.uid);
        }
      });
    } catch (e) {
      debugPrint('SyncService: Firebase is not available. Offline mode active: $e');
      isFirebaseAvailable.value = false;
    }
  }

  bool get isLoggedIn => currentUser.value != null;

  // Sign up
  Future<UserCredential?> signUp(String email, String password) async {
    if (!isFirebaseAvailable.value || _auth == null) return null;
    return await _auth!.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Login
  Future<UserCredential?> login(String email, String password) async {
    if (!isFirebaseAvailable.value || _auth == null) return null;
    return await _auth!.signInWithEmailAndPassword(email: email, password: password);
  }

  // Logout
  Future<void> logout() async {
    if (!isFirebaseAvailable.value || _auth == null) return;
    await _auth!.signOut();
  }

  // Synchronize everything
  Future<void> syncAll(String uid) async {
    if (!isFirebaseAvailable.value || _firestore == null) return;
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      final ctrl = Get.find<HabitController>();

      // 1. Sync habits
      await _syncCollection<HabitModel>(
        uid: uid,
        collectionName: 'habits',
        hiveBoxName: 'habits',
        fromMap: (id, map) => HabitModel(
          name: map['name'] ?? '',
          emoji: map['emoji'] ?? '✅',
          category: map['category'] ?? 'general',
          completedDates: List<String>.from(map['completedDates'] ?? []),
        ),
        toMap: (item) => {
          'name': item.name,
          'emoji': item.emoji,
          'category': item.category,
          'completedDates': item.completedDates,
        },
        getKey: (item) => item.name,
      );

      // 2. Sync jobs
      await _syncCollection<JobModel>(
        uid: uid,
        collectionName: 'jobs',
        hiveBoxName: 'jobs',
        fromMap: (id, map) => JobModel(
          company: map['company'] ?? '',
          role: map['role'] ?? '',
          status: map['status'] ?? 'applied',
          appliedDate: map['appliedDate'] ?? '',
          notes: map['notes'],
          jobUrl: map['jobUrl'],
        ),
        toMap: (item) => {
          'company': item.company,
          'role': item.role,
          'status': item.status,
          'appliedDate': item.appliedDate,
          'notes': item.notes,
          'jobUrl': item.jobUrl,
        },
        getKey: (item) => '${item.company}_${item.role}_${item.appliedDate}',
      );

      // 3. Sync skills
      await _syncCollection<SkillLogModel>(
        uid: uid,
        collectionName: 'skills',
        hiveBoxName: 'skills',
        fromMap: (id, map) => SkillLogModel(
          skill: map['skill'] ?? '',
          hoursStudied: (map['hoursStudied'] ?? 0.0).toDouble(),
          date: map['date'] ?? '',
          notes: map['notes'],
        ),
        toMap: (item) => {
          'skill': item.skill,
          'hoursStudied': item.hoursStudied,
          'date': item.date,
          'notes': item.notes,
        },
        getKey: (item) => '${item.skill}_${item.date}_${item.hoursStudied}',
      );

      // 4. Sync weekly reviews
      await _syncCollection<WeeklyReviewModel>(
        uid: uid,
        collectionName: 'weekly_reviews',
        hiveBoxName: 'weekly_reviews',
        fromMap: (id, map) => WeeklyReviewModel(
          weekEndDate: map['weekEndDate'] ?? '',
          grade: map['grade'] ?? 'C',
          applicationsSent: map['applicationsSent'] ?? 0,
          interviewsReceived: map['interviewsReceived'] ?? 0,
          skillHoursCompleted: (map['skillHoursCompleted'] ?? 0.0).toDouble(),
          habitCompletionRate: (map['habitCompletionRate'] ?? 0.0).toDouble(),
          grindScoreChange: map['grindScoreChange'] ?? 0,
          reflectionNotes: map['reflectionNotes'] ?? '',
          strengths: List<String>.from(map['strengths'] ?? []),
          weaknesses: List<String>.from(map['weaknesses'] ?? []),
        ),
        toMap: (item) => {
          'weekEndDate': item.weekEndDate,
          'grade': item.grade,
          'applicationsSent': item.applicationsSent,
          'interviewsReceived': item.interviewsReceived,
          'skillHoursCompleted': item.skillHoursCompleted,
          'habitCompletionRate': item.habitCompletionRate,
          'grindScoreChange': item.grindScoreChange,
          'reflectionNotes': item.reflectionNotes,
          'strengths': item.strengths,
          'weaknesses': item.weaknesses,
        },
        getKey: (item) => item.weekEndDate,
      );

      // Re-initialize controller data list from boxes
      ctrl.loadDataFromBoxes();
      debugPrint('SyncService: Sync completed successfully!');
    } catch (e) {
      debugPrint('SyncService: Error during sync: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> _syncCollection<T extends HiveObject>({
    required String uid,
    required String collectionName,
    required String hiveBoxName,
    required T Function(String id, Map<String, dynamic> data) fromMap,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) getKey,
  }) async {
    final box = Hive.box<T>(hiveBoxName);
    final colRef = _firestore!.collection('users').doc(uid).collection(collectionName);

    // Fetch cloud items
    final snapshot = await colRef.get();
    final cloudItems = {for (var doc in snapshot.docs) doc.id: doc.data()};

    // Stage items to push to cloud
    for (var item in box.values) {
      final key = getKey(item);
      final cleanKey = key.replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');

      await colRef.doc(cleanKey).set(toMap(item), SetOptions(merge: true));
    }

    // Merge cloud items into local Hive if they don't exist
    for (var entry in cloudItems.entries) {
      final cloudKey = entry.key;
      final data = entry.value;

      final localExists = box.values.any((item) {
        final key = getKey(item);
        final cleanKey = key.replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
        return cleanKey == cloudKey;
      });

      if (!localExists) {
        final newItem = fromMap(cloudKey, data);
        await box.add(newItem);
      }
    }
  }

  // Upload an individual record (triggered on local changes)
  Future<void> syncSingleRecord({
    required String collectionName,
    required Map<String, dynamic> data,
    required String docId,
  }) async {
    if (!isFirebaseAvailable.value || _firestore == null || !isLoggedIn) return;
    final uid = currentUser.value!.uid;
    final cleanId = docId.replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection(collectionName)
          .doc(cleanId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('SyncService: Failed to upload single record: $e');
    }
  }

  // Delete an individual record (triggered on local deletions)
  Future<void> deleteSingleRecord({
    required String collectionName,
    required String docId,
  }) async {
    if (!isFirebaseAvailable.value || _firestore == null || !isLoggedIn) return;
    final uid = currentUser.value!.uid;
    final cleanId = docId.replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection(collectionName)
          .doc(cleanId)
          .delete();
    } catch (e) {
      debugPrint('SyncService: Failed to delete single record: $e');
    }
  }
}
