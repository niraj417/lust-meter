import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final List<String> likedBy; // Array of user IDs who liked the comment
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.likedBy,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommentModel(
      id: documentId,
      text: map['text'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      likedBy: List<String>.from(map['likedBy'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }
}
