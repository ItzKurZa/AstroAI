import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'nearby_users_service.dart';

/// Service for authentication with proper Firebase validation
class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login with email and password
  /// 
  /// Validates credentials against Firebase Auth
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Attempt to sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Verify user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user?.uid).get();
      if (!userDoc.exists) {
        // User exists in Auth but not in Firestore - sign out and throw error
        await _auth.signOut();
        throw Exception('User account not found. Please sign up first.');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up first.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Login with phone number
  /// 
  /// Validates phone number exists in Firestore and matches user
  Future<UserCredential> loginWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Normalize phone number (remove spaces, dashes, etc.)
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);
      print('🔍 Searching for phone number: "$normalizedPhone" (original: "$phoneNumber")');
      
      // Find user by phone number in Firestore
      // Try exact match first
      var usersQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      // If not found, try with different formats
      if (usersQuery.docs.isEmpty) {
        print('⚠️ Exact match not found, trying alternative formats...');
        
        // Try without + prefix
        final withoutPlus = normalizedPhone.startsWith('+') 
            ? normalizedPhone.substring(1) 
            : normalizedPhone;
        usersQuery = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: withoutPlus)
            .limit(1)
            .get();
      }

      // If still not found, try with + prefix
      if (usersQuery.docs.isEmpty && !normalizedPhone.startsWith('+')) {
        print('⚠️ Trying with + prefix...');
        usersQuery = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: '+$normalizedPhone')
            .limit(1)
            .get();
      }

      // If still not found, get all users and search manually (for debugging)
      if (usersQuery.docs.isEmpty) {
        print('⚠️ Still not found, fetching all users to debug...');
        final allUsers = await _firestore.collection('users').limit(10).get();
        print('📋 Found ${allUsers.docs.length} users in database:');
        for (final doc in allUsers.docs) {
          final data = doc.data();
          final storedPhone = data['phoneNumber'] as String?;
          print('  - User ${doc.id}: phoneNumber="$storedPhone"');
        }
        throw Exception('No account found with this phone number. Please sign up first.');
      }

      final userDoc = usersQuery.docs.first;
      final userData = userDoc.data();
      final userEmail = userData['email'] as String?;

      if (userEmail == null || userEmail.isEmpty) {
        // User doesn't have email, need to set password during signup
        // For now, check if there's a password field
        final storedPassword = userData['password'] as String?;
        if (storedPassword == null || storedPassword != password) {
          throw Exception('Incorrect password. Please try again.');
        }
        // Password matches, but we can't use Firebase Auth without email
        // So we'll use anonymous auth and verify manually
        // In production, implement phone auth with OTP
        throw Exception('Phone authentication requires OTP verification. Please use email login or contact support.');
      }

      // User has email, use email/password auth
      return await loginWithEmail(email: userEmail, password: password);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Phone login failed: ${e.toString()}');
    }
  }

  /// Sign up with email and password
  /// 
  /// Creates new user in Firebase Auth and Firestore
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password strength
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if email already exists
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: 'dummy');
        // If we get here, user exists
        throw Exception('An account with this email already exists. Please login instead.');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Good, user doesn't exist, continue
        } else if (e.code == 'wrong-password') {
          // User exists with different password
          throw Exception('An account with this email already exists. Please login instead.');
        } else {
          // Other error, continue with signup
        }
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account with this email already exists. Please login instead.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use a stronger password.';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign up with phone number
  /// 
  /// Creates new user account with phone number
  Future<UserCredential> signUpWithPhone({
    required String phoneNumber,
    required String password,
    required String displayName,
    required String birthDate,
    required String birthTime,
    required String birthPlace,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Normalize phone number before checking
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);
      print('📝 Signup with normalized phone: "$normalizedPhone" (original: "$phoneNumber")');
      
      // Check if phone number already exists
      final existingUser = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: normalizedPhone)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('An account with this phone number already exists. Please login instead.');
      }

      // Validate password strength
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // For phone signup, we need to create an email-based account
      // Generate a unique email from phone number (use normalized version)
      final sanitizedPhone = normalizedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (sanitizedPhone.isEmpty) {
        throw Exception('Invalid phone number format');
      }
      final tempEmail = 'phone_$sanitizedPhone@astroai.temp';

      // Validate email format
      if (!_isValidEmail(tempEmail)) {
        throw Exception('Invalid email format generated from phone number');
      }

      // Create user in Firebase Auth with temp email
      UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: tempEmail,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Email already exists - user might have signed up before
          // Try to sign in with provided password
          try {
            userCredential = await _auth.signInWithEmailAndPassword(
              email: tempEmail,
              password: password,
            );
            // Check if phone number matches
            final existingUserDoc = await _firestore
                .collection('users')
                .doc(userCredential.user?.uid)
                .get();
            if (existingUserDoc.exists) {
              final existingData = existingUserDoc.data();
              final existingPhone = existingData?['phoneNumber'] as String?;
              final normalizedExistingPhone = existingPhone != null 
                  ? _normalizePhoneNumber(existingPhone) 
                  : null;
              if (normalizedExistingPhone == normalizedPhone) {
                // Same phone number and correct password - return existing user
                print('✅ User already exists, returning existing account');
                return userCredential;
              } else {
                // Different phone number - sign out and throw error
                await _auth.signOut();
                throw Exception('An account with this phone number already exists. Please login instead.');
              }
            }
          } on FirebaseAuthException catch (signInError) {
            if (signInError.code == 'wrong-password') {
              throw Exception('An account with this phone number already exists. Please login with the correct password.');
            }
            throw Exception('An account with this phone number already exists. Please login instead.');
          }
        } else {
          // Re-throw other Firebase Auth errors
          rethrow;
        }
      }

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      // Save user data to Firestore
      final userId = userCredential.user?.uid ?? '';
      if (userId.isEmpty) {
        await _auth.signOut();
        throw Exception('Failed to create user account');
      }

      // Update location if provided
      if (latitude != null && longitude != null) {
        await NearbyUsersService.instance.updateUserLocation(
          userId: userId,
          latitude: latitude,
          longitude: longitude,
        );
      }

      // Save user data to Firestore (DO NOT store password - it's in Firebase Auth)
      await _firestore.collection('users').doc(userId).set({
        'displayName': displayName,
        'phoneNumber': normalizedPhone, // Store normalized version
        'email': tempEmail, // Store temp email for reference
        // Password is stored securely in Firebase Auth, NOT in Firestore
        'birthDate': birthDate,
        'birthTime': birthTime,
        'birthPlace': birthPlace,
        'location': birthPlace,
        'birthLatitude': latitude ?? 0.0,
        'birthLongitude': longitude ?? 0.0,
        'planType': 'Free', // Default plan type
        'avatarUrl': 'assets/images/app/logo.png', // Default avatar
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account with this phone number already exists. Please login instead.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use a stronger password (at least 6 characters).';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please contact support.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message ?? e.code}';
      }
      print('❌ Firebase Auth error during signup: ${e.code} - ${e.message}');
      throw Exception(errorMessage);
    } catch (e) {
      // Clean up if user was created
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      print('❌ Error during signup: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: 'dummy');
      return true; // User exists
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      }
      if (e.code == 'wrong-password') {
        return true; // User exists
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check if phone number exists
  Future<bool> phoneExists(String phoneNumber) async {
    final query = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Normalize phone number to consistent format
  /// Removes spaces, dashes, and other formatting characters
  String _normalizePhoneNumber(String phoneNumber) {
    // Remove all spaces, dashes, parentheses, and other formatting
    var normalized = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    
    // Ensure it starts with + if it doesn't already
    if (!normalized.startsWith('+')) {
      // If it starts with 0, replace with country code
      if (normalized.startsWith('0')) {
        normalized = '+84${normalized.substring(1)}';
      } else {
        // Assume it's already without country code, add +84 for Vietnam
        normalized = '+84$normalized';
      }
    }
    
    return normalized;
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

