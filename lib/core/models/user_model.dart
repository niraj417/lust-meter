import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? partnerId;
  final int lustScore;
  final int emotionalScore;
  final int streak;
  final int points;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.partnerId,
    this.lustScore = 0,
    this.emotionalScore = 0,
    this.streak = 0,
    this.points = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      partnerId: map['partnerId'],
      lustScore: map['lustScore'] ?? 0,
      emotionalScore: map['emotionalScore'] ?? 0,
      streak: map['streak'] ?? 0,
      points: map['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'partnerId': partnerId,
      'lustScore': lustScore,
      'emotionalScore': emotionalScore,
      'streak': streak,
      'points': points,
    };
  }
}
