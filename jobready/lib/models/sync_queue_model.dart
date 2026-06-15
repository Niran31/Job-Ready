import 'package:hive/hive.dart';

part 'sync_queue_model.g.dart';

@HiveType(typeId: 6)
class SyncQueueModel extends HiveObject {
  @HiveField(0)
  final String action; // 'SET', 'DELETE'

  @HiveField(1)
  final String collection; // 'habits', 'jobs', 'skills', 'weekly_reviews'

  @HiveField(2)
  final String docId;

  @HiveField(3)
  final Map<String, dynamic>? data;

  @HiveField(4)
  final int timestamp;

  SyncQueueModel({
    required this.action,
    required this.collection,
    required this.docId,
    this.data,
    required this.timestamp,
  });
}
