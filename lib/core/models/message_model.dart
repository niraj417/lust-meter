import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text', 'image'
  final String? imageUrl;
  final DateTime? expiresAt;
  final bool isProtected;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.imageUrl,
    this.expiresAt,
    this.isProtected = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'text',
      imageUrl: map['imageUrl'],
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isProtected: map['isProtected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'imageUrl': imageUrl,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isProtected': isProtected,
    };
  }
}
