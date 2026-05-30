import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';
import '../models/user_settings.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    int age = 0,
    double weightKg = 70.0,
    double heightCm = 170.0,
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

    await _userDoc(uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );

    await createDefaultSettings(uid: uid);
  }

  Future<void> createDefaultSettings({
    required String uid,
  }) async {
    final now = DateTime.now();

    final settings = UserSettings(
      settingsId: 'main',
      userId: uid,
      distanceUnit: 'km',
      saveRoutes: true,
      allowLocation: true,
      dailyStepGoal: 10000,
      updatedAt: now,
    );

    await _userDoc(uid)
        .collection('settings')
        .doc('main')
        .set(settings.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserProfile.fromMap(doc.data()!);
  }

  Future<UserSettings?> getUserSettings(String uid) async {
    final doc = await _userDoc(uid).collection('settings').doc('main').get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserSettings.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    int? age,
    double? weightKg,
    double? heightCm,
    String? gender,
  }) async {
    final Map<String, dynamic> data = {
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (fullName != null) data['fullName'] = fullName;
    if (age != null) data['age'] = age;
    if (weightKg != null) data['weightKg'] = weightKg;
    if (heightCm != null) data['heightCm'] = heightCm;
    if (gender != null) data['gender'] = gender;

    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateDailyStepGoal({
    required String uid,
    required int dailyStepGoal,
  }) async {
    await _userDoc(uid).collection('settings').doc('main').update({
      'dailyStepGoal': dailyStepGoal,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
  Future<void> updateUserSettings({
    required String uid,
    String? distanceUnit,
    bool? saveRoutes,
    bool? allowLocation,
    int? dailyStepGoal,
  }) async {
    final Map<String, dynamic> data = {
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (distanceUnit != null) {
      data['distanceUnit'] = distanceUnit;
    }

    if (saveRoutes != null) {
      data['saveRoutes'] = saveRoutes;
    }

    if (allowLocation != null) {
      data['allowLocation'] = allowLocation;
    }

    if (dailyStepGoal != null) {
      data['dailyStepGoal'] = dailyStepGoal;
    }

    await _userDoc(uid)
        .collection('settings')
        .doc('main')
        .set(data, SetOptions(merge: true));
  }
}