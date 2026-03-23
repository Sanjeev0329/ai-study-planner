import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';

class AuthService {
  final _auth   = FirebaseAuth.instance;
  final _google = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Google Sign-In ────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Sign out first to force account picker every time
      await _google.signOut();

      final googleUser = await _google.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      // Make sure tokens are not null
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) return null;

      return UserModel(
        uid:      user.uid,
        email:    user.email ?? '',
        name:     user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      print('GOOGLE SIGN-IN ERROR: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      print('GOOGLE SIGN-IN ERROR: $e');
      return null;
    }
  }

  // ── Email Sign-In ─────────────────────────────────────────
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = result.user;
      if (user == null) return null;
      return UserModel(
        uid:      user.uid,
        email:    user.email ?? '',
        name:     user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      print('EMAIL LOGIN ERROR: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return null;
    }
  }

  // ── Email Sign-Up ─────────────────────────────────────────
  Future<UserModel?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = result.user;
      if (user == null) return null;
      await user.updateDisplayName(name);
      return UserModel(
        uid:      user.uid,
        email:    user.email ?? '',
        name:     name,
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      print('SIGN-UP ERROR: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      print('SIGN-UP ERROR: $e');
      return null;
    }
  }

  // ── Password Reset ────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}