import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String duration;
  final String colorHex;
  final int likes;
  final String authorId;
  final DateTime createdAt;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.duration,
    required this.colorHex,
    required this.likes,
    required this.authorId,
    required this.createdAt,
  });

  factory ChallengeModel.fromMap(Map<String, dynamic> data, String id) {
    return ChallengeModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '🔥',
      duration: data['duration'] ?? '1 Day',
      colorHex: data['colorHex'] ?? 'FFFFFF',
      likes: data['likes'] ?? 0,
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'duration': duration,
      'colorHex': colorHex,
      'likes': likes,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
