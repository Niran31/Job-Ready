import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';

class AuthController extends GetxController {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await _storeUserData(userCredential.user);
      
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar('Login Failed', e.message ?? 'An error occurred during login.');
    } catch (e) {
      _showErrorSnackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signupWithEmail(String name, String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());
      await userCredential.user?.reload();
      
      User? updatedUser = _auth.currentUser;
      await _storeUserData(updatedUser);
      
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar('Sign Up Failed', e.message ?? 'An error occurred during sign up.');
    } catch (e) {
      _showErrorSnackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _storeUserData(userCredential.user);
      
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar('Google Sign-In Failed', e.message ?? 'An error occurred.');
    } catch (e) {
      _showErrorSnackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        'Success',
        'Password reset link sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar('Reset Failed', e.message ?? 'An error occurred.');
    } catch (e) {
      _showErrorSnackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Sign out from Firebase and Google
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      // Clear Hive data
      await _clearHiveData();
      
      Get.offAllNamed('/login');
    } catch (e) {
      _showErrorSnackbar('Logout Error', 'Failed to log out properly.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _storeUserData(User? user) async {
    if (user == null) return;
    
    var box = await Hive.openBox('user_profile');
    await box.put('uid', user.uid);
    await box.put('email', user.email ?? '');
    await box.put('displayName', user.displayName ?? '');
  }

  Future<void> _clearHiveData() async {
    // Clear the specific user profile box
    var profileBox = await Hive.openBox('user_profile');
    await profileBox.clear();
    
    // As per user requirements "clear Hive data"
    // Clear all other boxes used by the app
    await Hive.box<HabitModel>('habits').clear();
    await Hive.box<JobModel>('jobs').clear();
    await Hive.box<SkillLogModel>('skills').clear();
    await Hive.box<WeeklyReviewModel>('weekly_reviews').clear();
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
