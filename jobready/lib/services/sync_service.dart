import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../models/sync_queue_model.dart';
import '../controllers/habit_controller.dart';

class SyncService extends GetxService {
  static SyncService get to => Get.find();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  late Box<SyncQueueModel> _queueBox;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  final List<StreamSubscription> _firestoreSubs = [];

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isFirebaseAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _queueBox = Hive.box<SyncQueueModel>('sync_queue');
    _checkFirebaseAvailability();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    _cancelFirestoreListeners();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        _drainQueue();
      }
    });
  }

  void _checkFirebaseAvailability() {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('SyncService: Firebase is not initialized. Offline mode active.');
        isFirebaseAvailable.value = false;
        return;
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      isFirebaseAvailable.value = true;
      currentUser.value = _auth!.currentUser;
      
      _auth!.authStateChanges().listen((user) {
        currentUser.value = user;
        if (user != null) {
          syncAll(user.uid);
        } else {
          _cancelFirestoreListeners();
        }
      }, onError: (e) {
        debugPrint('SyncService: Auth state listener error: $e');
      });
    } catch (e) {
      debugPrint('SyncService: Firebase is not available. Offline mode active: $e');
      isFirebaseAvailable.value = false;
    }
  }

  bool get isLoggedIn => currentUser.value != null;

  void _cancelFirestoreListeners() {
    for (var sub in _firestoreSubs) {
      sub.cancel();
    }
    _firestoreSubs.clear();
  }

  // Auto Sync: Setup Listeners & Initial Pull
  Future<void> syncAll(String uid) async {
    if (!isFirebaseAvailable.value || _firestore == null) return;
    
    _cancelFirestoreListeners();
    
    // Setup listeners for all collections
    _setupCollectionListener<HabitModel>(
      uid: uid,
      collectionName: 'habits',
      hiveBoxName: 'habits',
      fromMap: (id, map) => HabitModel(
        name: map['name'] ?? '',
        emoji: map['emoji'] ?? '✅',
        category: map['category'] ?? 'general',
        completedDates: List<String>.from(map['completedDates'] ?? []),
      ),
      getKey: (item) => item.name,
    );

    _setupCollectionListener<JobModel>(
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
      getKey: (item) => '${item.company}_${item.role}_${item.appliedDate}',
    );

    _setupCollectionListener<SkillLogModel>(
      uid: uid,
      collectionName: 'skills',
      hiveBoxName: 'skills',
      fromMap: (id, map) => SkillLogModel(
        skill: map['skill'] ?? '',
        hoursStudied: (map['hoursStudied'] ?? 0.0).toDouble(),
        date: map['date'] ?? '',
        notes: map['notes'],
      ),
      getKey: (item) => '${item.skill}_${item.date}_${item.hoursStudied}',
    );

    _setupCollectionListener<WeeklyReviewModel>(
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
      getKey: (item) => item.weekEndDate,
    );

    _drainQueue();
  }

  void _setupCollectionListener<T extends HiveObject>({
    required String uid,
    required String collectionName,
    required String hiveBoxName,
    required T Function(String id, Map<String, dynamic> data) fromMap,
    required String Function(T item) getKey,
  }) {
    final box = Hive.box<T>(hiveBoxName);
    final colRef = _firestore!.collection('users').doc(uid).collection(collectionName);

    final sub = colRef.snapshots().listen((snapshot) async {
      final ctrl = Get.find<HabitController>();
      bool updatedLocal = false;

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null) {
            final cloudKey = change.doc.id;
            
            // Check if local exists
            final localIndex = box.values.toList().indexWhere((item) {
              final key = getKey(item).replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
              return key == cloudKey;
            });

            final newItem = fromMap(cloudKey, data);
            
            if (localIndex != -1) {
              await box.putAt(localIndex, newItem);
            } else {
              await box.add(newItem);
            }
            updatedLocal = true;
          }
        } else if (change.type == DocumentChangeType.removed) {
          final cloudKey = change.doc.id;
          final localIndex = box.values.toList().indexWhere((item) {
            final key = getKey(item).replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
            return key == cloudKey;
          });
          if (localIndex != -1) {
            await box.deleteAt(localIndex);
            updatedLocal = true;
          }
        }
      }

      if (updatedLocal) {
        ctrl.loadDataFromBoxes();
      }
    }, onError: (error) {
      debugPrint('SyncService: Error listening to $collectionName: $error');
    });

    _firestoreSubs.add(sub);
  }

  // Backup All Local Data to Cloud
  Future<void> backupAll() async {
    if (!isFirebaseAvailable.value || _firestore == null || !isLoggedIn) {
      throw Exception('Not connected to Firebase');
    }
    
    final uid = currentUser.value!.uid;
    final batch = _firestore!.batch();
    
    // Helper for adding to batch
    void addToBatch<T extends HiveObject>(
      String collectionName,
      String hiveBoxName,
      Map<String, dynamic> Function(T item) toMap,
      String Function(T item) getKey,
    ) {
      final box = Hive.box<T>(hiveBoxName);
      final colRef = _firestore!.collection('users').doc(uid).collection(collectionName);
      
      for (var item in box.values) {
        final key = getKey(item).replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
        batch.set(colRef.doc(key), toMap(item), SetOptions(merge: true));
      }
    }

    addToBatch<HabitModel>('habits', 'habits', (item) => {
      'name': item.name,
      'emoji': item.emoji,
      'category': item.category,
      'completedDates': item.completedDates,
    }, (item) => item.name);

    addToBatch<JobModel>('jobs', 'jobs', (item) => {
      'company': item.company,
      'role': item.role,
      'status': item.status,
      'appliedDate': item.appliedDate,
      'notes': item.notes,
      'jobUrl': item.jobUrl,
    }, (item) => '${item.company}_${item.role}_${item.appliedDate}');

    addToBatch<SkillLogModel>('skills', 'skills', (item) => {
      'skill': item.skill,
      'hoursStudied': item.hoursStudied,
      'date': item.date,
      'notes': item.notes,
    }, (item) => '${item.skill}_${item.date}_${item.hoursStudied}');

    addToBatch<WeeklyReviewModel>('weekly_reviews', 'weekly_reviews', (item) => {
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
    }, (item) => item.weekEndDate);

    await batch.commit();
  }

  // Restore All Cloud Data to Local (Overwrites local)
  Future<void> restoreAll() async {
    if (!isFirebaseAvailable.value || _firestore == null || !isLoggedIn) {
      throw Exception('Not connected to Firebase');
    }
    
    // Clear local boxes
    await Hive.box<HabitModel>('habits').clear();
    await Hive.box<JobModel>('jobs').clear();
    await Hive.box<SkillLogModel>('skills').clear();
    await Hive.box<WeeklyReviewModel>('weekly_reviews').clear();
    
    // Pull fresh data
    final uid = currentUser.value!.uid;
    
    Future<void> pullCollection<T extends HiveObject>({
      required String collectionName,
      required String hiveBoxName,
      required T Function(String id, Map<String, dynamic> data) fromMap,
    }) async {
      final snapshot = await _firestore!.collection('users').doc(uid).collection(collectionName).get();
      final box = Hive.box<T>(hiveBoxName);
      
      for (var doc in snapshot.docs) {
        if (doc.data().isNotEmpty) {
          await box.add(fromMap(doc.id, doc.data()));
        }
      }
    }

    await pullCollection<HabitModel>(
      collectionName: 'habits',
      hiveBoxName: 'habits',
      fromMap: (id, map) => HabitModel(
        name: map['name'] ?? '',
        emoji: map['emoji'] ?? '✅',
        category: map['category'] ?? 'general',
        completedDates: List<String>.from(map['completedDates'] ?? []),
      ),
    );

    await pullCollection<JobModel>(
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
    );

    await pullCollection<SkillLogModel>(
      collectionName: 'skills',
      hiveBoxName: 'skills',
      fromMap: (id, map) => SkillLogModel(
        skill: map['skill'] ?? '',
        hoursStudied: (map['hoursStudied'] ?? 0.0).toDouble(),
        date: map['date'] ?? '',
        notes: map['notes'],
      ),
    );

    await pullCollection<WeeklyReviewModel>(
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
    );

    Get.find<HabitController>().loadDataFromBoxes();
  }

  // Queue and Upload Individual Records
  Future<void> syncSingleRecord({
    required String collectionName,
    required Map<String, dynamic> data,
    required String docId,
  }) async {
    if (!isLoggedIn) return;
    
    final cleanId = docId.replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
    
    // Add to queue first
    await _queueBox.add(SyncQueueModel(
      action: 'SET',
      collection: collectionName,
      docId: cleanId,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
    
    _drainQueue();
  }

  Future<void> deleteSingleRecord({
    required String collectionName,
    required String docId,
  }) async {
    if (!isLoggedIn) return;
    
    final cleanId = docId.replaceAll(RegExp(r'[/\#\$\?\]\[]'), '_');
    
    // Add to queue first
    await _queueBox.add(SyncQueueModel(
      action: 'DELETE',
      collection: collectionName,
      docId: cleanId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
    
    _drainQueue();
  }

  Future<void> _drainQueue() async {
    if (!isFirebaseAvailable.value || _firestore == null || !isLoggedIn) return;
    
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      debugPrint('SyncService: Offline. Keeping items in queue.');
      return;
    }

    if (_queueBox.isEmpty) return;

    final uid = currentUser.value!.uid;
    final itemsToProcess = _queueBox.values.toList();
    
    for (var item in itemsToProcess) {
      try {
        final docRef = _firestore!.collection('users').doc(uid).collection(item.collection).doc(item.docId);
        
        if (item.action == 'SET' && item.data != null) {
          await docRef.set(item.data!, SetOptions(merge: true));
        } else if (item.action == 'DELETE') {
          await docRef.delete();
        }
        
        await item.delete(); // Remove from queue on success
      } catch (e) {
        debugPrint('SyncService: Queue drain error for ${item.docId}: $e');
        // Will retry on next connectivity change
      }
    }
  }
}
