import 'package:cloud_firestore/cloud_firestore.dart';

class PositionModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String level;
  final String colorHex;
  final String detailedInstruction;
  final String tips;
  final String? imageUrl;

  final int likes;
  final String? authorId;
  final DateTime? createdAt;

  PositionModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.level,
    required this.colorHex,
    required this.detailedInstruction,
    required this.tips,
    this.imageUrl,
    this.likes = 0,
    this.authorId,
    this.createdAt,
  });

  factory PositionModel.fromMap(Map<String, dynamic> map, String id) {
    return PositionModel(
      id: id,
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '🔥',
      description: map['description'] ?? '',
      level: map['level'] ?? 'Intermediate',
      colorHex: map['colorHex'] ?? 'E63950',
      detailedInstruction: map['detailedInstruction'] ?? '',
      tips: map['tips'] ?? '',
      imageUrl: map['imageUrl'],
      likes: map['likes'] ?? 0,
      authorId: map['authorId'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'description': description,
      'level': level,
      'colorHex': colorHex,
      'detailedInstruction': detailedInstruction,
      'tips': tips,
      'imageUrl': imageUrl,
      'likes': likes,
      'authorId': authorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
