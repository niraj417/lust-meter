import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../core/constants/app_constants.dart';
import '../core/models/doctor_model.dart';
import '../core/models/game_session_model.dart';
import '../core/models/kink_interaction_model.dart';
import '../core/models/message_model.dart';
import '../core/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Users ---
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> addPoints(String uid, int points) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'lustScore': FieldValue.increment(points),
      'points': FieldValue.increment(points),
    });
  }

  // --- Partner Connections & Invites ---
  Future<String> getOrCreateInviteCode(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('inviteCode')) {
      final code = doc.data()!['inviteCode'] as String?;
      if (code != null && code.isNotEmpty) return code;
    }
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    final newCode = List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({'inviteCode': newCode}, SetOptions(merge: true));
    return newCode;
  }

  Future<void> connectWithPartner(String uid, String partnerCode) async {
    final snapshot = await _firestore.collection(AppConstants.usersCollection).where('inviteCode', isEqualTo: partnerCode).get();
    if (snapshot.docs.isEmpty) throw Exception('Invalid invite code');
    final partnerDoc = snapshot.docs.first;
    if (partnerDoc.id == uid) throw Exception('Cannot connect with yourself');
    
    // Create connection
    final docRef = _firestore.collection(AppConstants.partnersCollection).doc();
    await docRef.set({
      'users': [uid, partnerDoc.id],
      'status': 'connected',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update both users
    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({'partnerId': partnerDoc.id}, SetOptions(merge: true));
    await _firestore.collection(AppConstants.usersCollection).doc(partnerDoc.id).set({'partnerId': uid}, SetOptions(merge: true));
  }

  Stream<String?> getPartnerIdStream(String uid) {
    return _firestore.collection(AppConstants.usersCollection).doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data()?['partnerId'] as String?;
    });
  }

  Stream<PartnerConnectionModel?> getPartnerConnectionStream(String uid) {
    return _firestore
        .collection(AppConstants.partnersCollection)
        .where('users', arrayContains: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return PartnerConnectionModel.fromMap(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    });
  }

  // --- Kink Interactions ---
  Future<void> recordKinkInteraction(String userId, String kinkId, String status) async {
    final docId = '${userId}_$kinkId';
    await _firestore.collection(AppConstants.kinkInteractionsCollection).doc(docId).set({
      'userId': userId,
      'kinkId': kinkId,
      'status': status,
      'partnerMatch': false, // Would require checking partner's interaction separately
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<KinkInteractionModel>> getUserKinkInteractions(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.kinkInteractionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => KinkInteractionModel.fromMap(doc.data(), doc.id)).toList();
  }

  // --- Game Sessions ---
  Future<void> recordGameSession(GameSessionModel session) async {
    await _firestore.collection(AppConstants.gameSessionsCollection).doc(session.sessionId).set(session.toMap());
    // Give all participants the awarded points
    for (String uid in session.participants) {
      await addPoints(uid, session.pointsAwarded);
    }
  }

  // --- Doctors / Consultations ---
  Future<List<DoctorModel>> getDoctors() async {
    await _seedDoctorsIfEmpty();
    final snapshot = await _firestore.collection(AppConstants.doctorsCollection).get();
    return snapshot.docs.map((doc) => DoctorModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> _seedDoctorsIfEmpty() async {
    try {
      final snap = await _firestore.collection(AppConstants.doctorsCollection).limit(1).get();
      if (snap.docs.isEmpty) {
        final batch = _firestore.batch();
        final mockDoctors = [
          {'name': 'Dr. Emily Vance', 'specialty': 'Couples Therapy', 'photoUrl': 'https://i.pravatar.cc/150?img=1', 'rating': 4.9, 'isOnline': true},
          {'name': 'Dr. Marcus Thorne', 'specialty': 'Sexology', 'photoUrl': 'https://i.pravatar.cc/150?img=33', 'rating': 4.8, 'isOnline': false},
          {'name': 'Dr. Sarah Lin', 'specialty': 'Relationship Counseling', 'photoUrl': 'https://i.pravatar.cc/150?img=5', 'rating': 5.0, 'isOnline': true},
        ];

        for (var docItem in mockDoctors) {
          final ref = _firestore.collection(AppConstants.doctorsCollection).doc();
          batch.set(ref, docItem);
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  // --- Messaging (Between Partners) ---
  Future<void> sendMessage(String connectionId, MessageModel message) async {
    await _firestore
        .collection(AppConstants.partnersCollection)
        .doc(connectionId)
        .collection(AppConstants.messagesCollection)
        .doc(message.messageId)
        .set(message.toMap());
  }

  Stream<List<MessageModel>> getMessagesStream(String connectionId) {
    return _firestore
        .collection(AppConstants.partnersCollection)
        .doc(connectionId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList());
  }
}
