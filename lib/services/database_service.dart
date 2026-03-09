import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import '../core/constants/app_constants.dart';
import '../core/models/doctor_model.dart';
import '../core/models/game_session_model.dart';
import '../core/models/kink_interaction_model.dart';
import '../core/models/kink_request_model.dart';
import '../core/models/message_model.dart';
import '../core/models/partner_connection_model.dart';
import '../core/models/user_model.dart';
import '../../features/explore/models/challenge_model.dart';
import '../../features/explore/models/challenge_interaction_model.dart';
import '../../core/models/comment_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Users ---
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection(AppConstants.usersCollection).doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> addPoints(String uid, int points) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'lustScore': FieldValue.increment(points),
      'points': FieldValue.increment(points),
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update(data);
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

  Stream<List<PartnerConnectionModel>> getUserConnectionsStream(String uid) {
    return _firestore
        .collection(AppConstants.partnersCollection)
        .where('users', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PartnerConnectionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> deletePartnerConnection(String connectionId) async {
    await _firestore.collection(AppConstants.partnersCollection).doc(connectionId).delete();
  }

  // --- Kink Interactions ---

  Future<List<KinkInteractionModel>> getUserKinkInteractions(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.kinkInteractionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => KinkInteractionModel.fromMap(doc.data(), doc.id)).toList();
  }

  // Find all users interested in a specific kink
  Future<List<UserModel>> getUsersInterestedInKink(String kinkId, String currentUserId) async {
    final interactionSnapshot = await _firestore
        .collection(AppConstants.kinkInteractionsCollection)
        .where('kinkId', isEqualTo: kinkId)
        .where('status', isEqualTo: 'tried') // assuming 'tried' or 'liked' means interested
        .get();

    List<UserModel> users = [];
    for (var doc in interactionSnapshot.docs) {
      final interaction = KinkInteractionModel.fromMap(doc.data(), doc.id);
      if (interaction.userId != currentUserId) {
        final user = await getUser(interaction.userId);
        if (user != null) {
          users.add(user);
        }
      }
    }
    
    // Also include 'liked' if they haven't tried but want to
    final likedSnapshot = await _firestore
        .collection(AppConstants.kinkInteractionsCollection)
        .where('kinkId', isEqualTo: kinkId)
        .where('status', isEqualTo: 'liked')
        .get();
        
    for (var doc in likedSnapshot.docs) {
      final interaction = KinkInteractionModel.fromMap(doc.data(), doc.id);
      if (interaction.userId != currentUserId && !users.any((u) => u.uid == interaction.userId)) {
        final user = await getUser(interaction.userId);
        if (user != null) {
          users.add(user);
        }
      }
    }

    return users;
  }

  // Send a kink request
  Future<void> sendKinkRequest(String fromUser, String toUser, String kinkId) async {
    // Check if request already exists
    final existingParams = await _firestore.collection(AppConstants.kinkRequestsCollection)
        .where('fromUserId', isEqualTo: fromUser)
        .where('toUserId', isEqualTo: toUser)
        .where('kinkId', isEqualTo: kinkId)
        .get();

    if (existingParams.docs.isNotEmpty) return;

    await _firestore.collection(AppConstants.kinkRequestsCollection).add({
      'fromUserId': fromUser,
      'toUserId': toUser,
      'kinkId': kinkId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get stream of received kink requests
  Stream<List<KinkRequestModel>> getReceivedKinkRequestsStream(String userId) {
    return _firestore
        .collection(AppConstants.kinkRequestsCollection)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => KinkRequestModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Accept/reject kink request
  Future<void> updateKinkRequestStatus(String requestId, String status) async {
    await _firestore.collection(AppConstants.kinkRequestsCollection).doc(requestId).update({
      'status': status,
    });
  }

  Future<void> acceptKinkRequest(KinkRequestModel request) async {
    // 1. update status
    await updateKinkRequestStatus(request.id, 'accepted');
    
    // 2. check if connection already exists
    final existing = await _firestore.collection(AppConstants.partnersCollection)
      .where('users', arrayContains: request.fromUserId)
      .get();
      
    bool alreadyConnected = false;
    for (var doc in existing.docs) {
      final users = List<String>.from(doc.data()['users'] ?? []);
      if (users.contains(request.toUserId)) {
        alreadyConnected = true;
        break;
      }
    }

    // 3. create partner connection string for chat if not already connected
    if (!alreadyConnected) {
      await _firestore.collection(AppConstants.partnersCollection).add({
        'users': [request.fromUserId, request.toUserId],
        'status': 'connected',
        'type': 'kink',
        'kinkId': request.kinkId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> rejectKinkRequest(String requestId) async {
    await updateKinkRequestStatus(requestId, 'rejected');
  }

  // --- Challenges ---
  Stream<List<ChallengeModel>> getChallengesStream() {
    return _firestore
        .collection(AppConstants.challengesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChallengeModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addChallenge(ChallengeModel challenge) async {
    await _firestore.collection(AppConstants.challengesCollection).add(challenge.toMap());
  }

  Future<void> recordChallengeInteraction(String userId, String challengeId, {bool? isLiked, bool? isTried}) async {
    final docId = '${userId}_$challengeId';
    final docRef = _firestore.collection(AppConstants.challengeInteractionsCollection).doc(docId);
    
    final updateData = <String, dynamic>{
      'userId': userId,
      'challengeId': challengeId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (isLiked != null) {
      updateData['status'] = isLiked ? 'liked' : 'none';
      // Increment or decrement likes on the challenge document
      await _firestore.collection(AppConstants.challengesCollection).doc(challengeId).update({
        'likes': FieldValue.increment(isLiked ? 1 : -1)
      });
    }
    if (isTried != null) {
      updateData['isTried'] = isTried;
    }

    await docRef.set(updateData, SetOptions(merge: true));
  }

  Stream<ChallengeInteractionModel?> getChallengeInteractionStream(String userId, String challengeId) {
    final docId = '${userId}_$challengeId';
    return _firestore
        .collection(AppConstants.challengeInteractionsCollection)
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return ChallengeInteractionModel.fromMap(doc.data()!, doc.id);
    });
  }

  // --- Kinks Interactions ---
  Future<void> recordKinkInteraction(String userId, String kinkId, {bool? isLiked, bool? isTried}) async {
    final docId = '${userId}_$kinkId';
    final docRef = _firestore.collection(AppConstants.kinkInteractionsCollection).doc(docId);
    
    final updateData = <String, dynamic>{
      'userId': userId,
      'kinkId': kinkId,
      'partnerMatch': false,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isLiked != null) {
      updateData['status'] = isLiked ? 'liked' : 'none';
      // Increment or decrement likes on the kink document
      await _firestore.collection(AppConstants.kinksCollection).doc(kinkId).update({
        'likes': FieldValue.increment(isLiked ? 1 : -1)
      });
    }

    if (isTried != null) {
      updateData['isTried'] = isTried;
    }

    await docRef.set(updateData, SetOptions(merge: true));
  }

  Stream<Map<String, bool>> getKinkInteractionStream(String userId, String kinkId) {
    final docId = '${userId}_$kinkId';
    return _firestore
        .collection(AppConstants.kinkInteractionsCollection)
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return {'isLiked': false, 'isTried': false};
      final data = doc.data()!;
      return {
        'isLiked': data['status'] == 'liked',
        'isTried': data['isTried'] == true,
      };
    });
  }

  // --- Generic Comments ---
  Stream<List<CommentModel>> getCommentsStream(String collection, String docId) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CommentModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addComment(String collection, String docId, CommentModel comment) async {
    await _firestore.collection(collection).doc(docId).collection('comments').add(comment.toMap());
  }

  Future<void> toggleCommentLike(String collection, String parentDocId, String commentId, String userId, bool isLiked) async {
    final commentRef = _firestore.collection(collection).doc(parentDocId).collection('comments').doc(commentId);
    if (isLiked) {
      await commentRef.update({
        'likedBy': FieldValue.arrayUnion([userId])
      });
    } else {
      await commentRef.update({
        'likedBy': FieldValue.arrayRemove([userId])
      });
    }
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

  Future<String> uploadChatImage(String connectionId, File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(AppConstants.chatImagesStorage).child(connectionId).child(fileName);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
