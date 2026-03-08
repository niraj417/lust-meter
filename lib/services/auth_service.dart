import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _googleInitialized = false;

  /// Stream of auth state changes (null when signed out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email & password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Create account with email & password
  Future<UserCredential> signUpWithEmail(
      String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user?.updateDisplayName(name);
    await _createUserDocument(cred.user!, name);
    return cred;
  }

  /// Sign in with Google (google_sign_in v7 API)
  /// In v7, GoogleSignInAuthentication only provides idToken.
  /// We use GoogleProvider credential with idToken only.
  Future<UserCredential?> signInWithGoogle() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }

    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    // v7: authentication exposes idToken only (no accessToken)
    final idToken = googleUser.authentication.idToken;

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    if (userCred.additionalUserInfo?.isNewUser == true) {
      await _createUserDocument(
          userCred.user!, userCred.user!.displayName ?? 'User');
    }
    return userCred;
  }

  /// Sign out
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  /// Password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Create Firestore user document on first sign-up
  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'photoUrl': user.photoURL,
      'partnerId': null,
      'lustScore': 50,
      'emotionalScore': 50,
      'physicalScore': 50,
      'bondScore': 50,
      'dailyStreak': 0,
      'totalPoints': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
