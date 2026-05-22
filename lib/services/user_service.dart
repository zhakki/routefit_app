import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import '../models/user_settings.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    int age = 0,
    double weightKg = 70,
    double heightCm = 170,
    String gender = '',
  }) async {
    final now = DateTime.now();

    final profile = UserProfile(
      uid: uid,
      email: email,
      fullName: fullName,
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      gender: gender,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('user_profiles').doc(uid).set(profile.toMap());

    await createDefaultSettings(uid: uid);
  }

  Future<void> createDefaultSettings({
    required String uid,
  }) async {
    final now = DateTime.now();

    final settings = UserSettings(
      settingsId: uid,
      userId: uid,
      distanceUnit: 'km',
      saveRoutes: true,
      allowLocation: true,
      dailyStepGoal: 10000,
      updatedAt: now,
    );

    await _firestore.collection('user_settings').doc(uid).set(settings.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('user_profiles').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserProfile.fromMap(doc.data()!);
  }

  Future<UserSettings?> getUserSettings(String uid) async {
    final doc = await _firestore.collection('user_settings').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserSettings.fromMap(doc.data()!);
  }

  Future<void> updateDailyStepGoal({
    required String uid,
    required int dailyStepGoal,
  }) async {
    await _firestore.collection('user_settings').doc(uid).update({
      'dailyStepGoal': dailyStepGoal,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}