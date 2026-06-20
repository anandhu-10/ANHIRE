import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import '../core/services/firebase_service.dart';

abstract class AuthRepository {
  Future<UserCredential?> signUp(String email, String password);
  Future<UserCredential?> signIn(String email, String password);
  Future<void> signOut();
  Future<UserCredential?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  String? getCurrentUserUid();
  String? getCurrentUserEmail();
  Future<String> getUserRole(String uid);
}

class AuthRepositoryImpl implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();

  static const String _authBoxName = "auth_session_box";

  AuthRepositoryImpl() {
    if (!FirebaseService.isFirebaseAvailable) {
      Hive.openBox(_authBoxName);
    }
  }

  bool get _useFirebase => FirebaseService.isFirebaseAvailable;

  @override
  Future<UserCredential?> signUp(String email, String password) async {
    if (!_useFirebase) {
      // Simulate signup in local cache
      final box = Hive.box(_authBoxName);
      final uid = "mock_uid_${email.replaceAll('@', '_').replaceAll('.', '_')}";
      await box.put("current_uid", uid);
      await box.put("current_email", email);
      await box.put("role_$uid", "student"); // Default signup role is student
      return null;
    }
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential?> signIn(String email, String password) async {
    if (!_useFirebase) {
      // Offline Demo Account Check
      final cleanEmail = email.trim().toLowerCase();
      String role = "student";
      String uid = "mock_student_uid";

      if (cleanEmail == "student@placementpro.com" && password == "123456") {
        uid = "mock_student_uid";
        role = "student";
      } else if (cleanEmail == "admin@placementpro.com" && password == "anandhu@123") {
        uid = "mock_admin_uid";
        role = "admin";
      } else if (password.length >= 6) {
        // Allow arbitrary log in for demo purposes
        uid = "mock_uid_${cleanEmail.replaceAll('@', '_').replaceAll('.', '_')}";
        role = "student";
      } else {
        throw Exception("Invalid credentials. Try demo accounts!");
      }

      final box = Hive.box(_authBoxName);
      await box.put("current_uid", uid);
      await box.put("current_email", cleanEmail);
      await box.put("role_$uid", role);
      return null;
    }
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    if (!_useFirebase) {
      final box = Hive.box(_authBoxName);
      await box.delete("current_uid");
      await box.delete("current_email");
      return;
    }
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (!_useFirebase) {
      final box = Hive.box(_authBoxName);
      const uid = "mock_google_user_uid";
      await box.put("current_uid", uid);
      await box.put("current_email", "google.student@placementpro.com");
      await box.put("role_$uid", "student");
      return null;
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (!_useFirebase) return;
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_useFirebase) return;
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  String? getCurrentUserUid() {
    if (!_useFirebase) {
      if (!Hive.isBoxOpen(_authBoxName)) return null;
      final box = Hive.box(_authBoxName);
      return box.get("current_uid") as String?;
    }
    return _auth.currentUser?.uid;
  }

  @override
  String? getCurrentUserEmail() {
    if (!_useFirebase) {
      if (!Hive.isBoxOpen(_authBoxName)) return null;
      final box = Hive.box(_authBoxName);
      return box.get("current_email") as String?;
    }
    return _auth.currentUser?.email;
  }

  @override
  Future<String> getUserRole(String uid) async {
    if (!_useFirebase) {
      if (!Hive.isBoxOpen(_authBoxName)) return "student";
      final box = Hive.box(_authBoxName);
      return box.get("role_$uid", defaultValue: "student") as String;
    }
    return "student";
  }
}
