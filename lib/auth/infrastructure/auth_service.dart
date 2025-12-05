import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:result_type/result_type.dart';
import '../domain/i_auth_service.dart';
import '../domain/auth_user_model.dart';

class AuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<AuthUserModel, AuthException>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return Failure(AuthException(AuthError.unknown));
      final userModel = AuthUserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: username,
        photoUrl: user.photoURL ?? '',
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());
      return Success(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use')
        return Failure(AuthException(AuthError.emailAlreadyInUse));
      if (e.code == 'weak-password')
        return Failure(AuthException(AuthError.weakPassword));
      return Failure(AuthException(AuthError.invalidCredentials));
    } catch (_) {
      return Failure(AuthException(AuthError.unknown));
    }
  }

  @override
  Future<Result<AuthUserModel, AuthException>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return Failure(AuthException(AuthError.unknown));
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return Failure(AuthException(AuthError.unknown));
      final userModel = AuthUserModel.fromJson(doc.data()!);
      return Success(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Failure(AuthException(AuthError.invalidCredentials));
      }
      return Failure(AuthException(AuthError.unknown));
    } catch (_) {
      return Failure(AuthException(AuthError.unknown));
    }
  }

  @override
  Future<Result<void, AuthException>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Success(null);
    } catch (_) {
      return Failure(AuthException(AuthError.unknown));
    }
  }

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AuthUserModel.fromJson(doc.data()!);
  }
}
