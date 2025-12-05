import 'package:firebase_auth/firebase_auth.dart';

/// Get current user ID from Firebase Auth
/// 
/// Throws exception if no user is logged in
/// This ensures we only work with real authenticated users
String get currentUserId {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No user logged in. Please login or signup first.');
  }
  return user.uid;
}

