import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_parser.dart';

class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final int age;
  final double weightKg;
  final double heightCm;
  final String gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      age: FirestoreParser.parseInt(map['age']),
      weightKg: FirestoreParser.parseDouble(map['weightKg']),
      heightCm: FirestoreParser.parseDouble(map['heightCm']),
      gender: map['gender'] ?? '',
      createdAt: FirestoreParser.parseDateTime(map['createdAt']),
      updatedAt: FirestoreParser.parseDateTime(map['updatedAt']),
    );
  }
}