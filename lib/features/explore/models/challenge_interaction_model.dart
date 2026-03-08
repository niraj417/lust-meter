import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeInteractionModel {
  final String id;
  final String userId;
  final String challengeId;
  final String status; // 'liked', 'none'
  final bool isTried;
  final DateTime updatedAt;

  ChallengeInteractionModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.status,
    required this.isTried,
    required this.updatedAt,
  });

  factory ChallengeInteractionModel.fromMap(Map<String, dynamic> data, String id) {
    return ChallengeInteractionModel(
      id: id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      status: data['status'] ?? 'none',
      isTried: data['isTried'] ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'status': status,
      'isTried': isTried,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
