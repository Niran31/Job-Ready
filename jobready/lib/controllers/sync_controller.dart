import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

class SyncController extends GetxController {
  static SyncController get to => Get.find();

  final RxBool isSyncing = false.obs;
  final RxString lastSyncedTime = 'Never'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLastSynced();
  }

  Future<void> _loadLastSynced() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('last_synced_time');
    if (timeStr != null) {
      final time = DateTime.tryParse(timeStr);
      if (time != null) {
        lastSyncedTime.value = _formatTimeAgo(time);
      }
    }
  }

  Future<void> updateLastSynced() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('last_synced_time', now.toIso8601String());
    lastSyncedTime.value = 'Just now';
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} mins ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  void _showSyncOverlay() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.cardColor(Get.context!),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Syncing...',
                  style: TextStyle(
                    color: AppTheme.textPrimary(Get.context!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideSyncOverlay() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> backupNow() async {
    if (isSyncing.value) return;
    try {
      isSyncing.value = true;
      _showSyncOverlay();
      
      await SyncService.to.backupAll();
      await updateLastSynced();
      
      _hideSyncOverlay();
      Get.snackbar(
        'Backup Successful',
        'All your data has been securely backed up to the cloud.',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      _hideSyncOverlay();
      Get.snackbar(
        'Backup Failed',
        'Could not complete backup: ${e.toString()}',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> restoreData() async {
    if (isSyncing.value) return;
    try {
      isSyncing.value = true;
      _showSyncOverlay();
      
      await SyncService.to.restoreAll();
      await updateLastSynced();
      
      _hideSyncOverlay();
      Get.snackbar(
        'Restore Successful',
        'Your local data has been overwritten with the cloud backup.',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      _hideSyncOverlay();
      Get.snackbar(
        'Restore Failed',
        'Could not restore data: ${e.toString()}',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSyncing.value = false;
    }
  }
}
