import 'package:cloud_firestore/cloud_firestore.dart';

class KinkModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int likes;
  final String iconName;
  final String colorHex;
  final String? safetyTips;

  final String? authorId;
  final DateTime? createdAt;

  KinkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.likes,
    required this.iconName,
    required this.colorHex,
    this.safetyTips,
    this.authorId,
    this.createdAt,
  });

  factory KinkModel.fromMap(Map<String, dynamic> map, String id) {
    return KinkModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      likes: map['likes'] ?? 0,
      iconName: map['iconName'] ?? 'star',
      colorHex: map['colorHex'] ?? '9B30FF',
      safetyTips: map['safetyTips'],
      authorId: map['authorId'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'likes': likes,
      'iconName': iconName,
      'colorHex': colorHex,
      'safetyTips': safetyTips,
      'authorId': authorId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
