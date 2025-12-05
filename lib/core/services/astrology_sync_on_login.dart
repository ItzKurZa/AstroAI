import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'freeastrology_firebase_sync.dart';
import 'location_service.dart';
import 'local_cache_service.dart';
import 'tip_of_day_service.dart';

/// Service to sync astrology data when user logs in
/// 
/// This service checks if user has birth chart data and syncs it if needed
class AstrologySyncOnLogin {
  static AstrologySyncOnLogin? _instance;
  static AstrologySyncOnLogin get instance {
    _instance ??= AstrologySyncOnLogin._();
    return _instance!;
  }

  AstrologySyncOnLogin._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FreeAstrologyFirebaseSync _syncService = FreeAstrologyFirebaseSync.instance;
  
  // Track if sync is in progress to prevent multiple simultaneous calls
  bool _isSyncing = false;
  String? _lastSyncedUserId;
  DateTime? _lastSyncTime;
  // Session-level flag to ensure sync only happens once per app session
  bool _hasSyncedInSession = false;

  /// Check and sync astrology data after login
  /// 
  /// This will:
  /// 1. Check if user has birth chart data
  /// 2. If missing or outdated, sync from API
  /// 3. Update daily horoscope if needed
  /// 
  /// Note: This method is safe to call multiple times - it will only sync once per user per session
  Future<void> syncAfterLogin() async {
    // Prevent multiple simultaneous syncs
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in, skipping astrology sync');
        return;
      }

      final userId = user.uid;
      
      // Skip if we already synced in this session (prevents multiple syncs on navigation)
      if (_hasSyncedInSession && _lastSyncedUserId == userId) {
        print('✅ Already synced in this session for user $userId, skipping...');
        return;
      }
      
      // Also skip if we just synced this user recently (within last 10 minutes)
      // This prevents syncs when app restarts or hot reload
      if (_lastSyncedUserId == userId && _lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
        if (timeSinceLastSync.inMinutes < 10) {
          print('✅ Recently synced for user $userId (${timeSinceLastSync.inSeconds}s ago), skipping...');
          // Mark as synced in session to prevent further checks
          _hasSyncedInSession = true;
          return;
        }
      }

      _isSyncing = true;
      print('🔄 Checking astrology data for user: $userId');

      // Get user profile
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('User profile not found, skipping sync');
        return;
      }

      final userData = userDoc.data()!;
      final birthDateStr = userData['birthDate'] as String?;
      final birthTimeStr = userData['birthTime'] as String?;
      final birthPlaceStr = userData['birthPlace'] as String?;
      final latitude = (userData['birthLatitude'] as num?)?.toDouble() ?? 0.0;
      final longitude = (userData['birthLongitude'] as num?)?.toDouble() ?? 0.0;
      final sunSign = userData['sunSign'] as String?;

      // Check if we have required data
      if (birthDateStr == null || birthTimeStr == null) {
        print('⚠️ Missing birth date/time, cannot sync astrology data');
        return;
      }

      // Parse birth date
      DateTime? birthDate;
      try {
        if (birthDateStr.contains('/')) {
          final parts = birthDateStr.split('/');
          if (parts.length == 3) {
            birthDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } else if (birthDateStr.contains('-')) {
          birthDate = DateTime.parse(birthDateStr);
        }
      } catch (e) {
        print('❌ Error parsing birth date: $e');
        return;
      }

      if (birthDate == null) {
        print('❌ Invalid birth date format');
        return;
      }

      // Check local cache first (fastest)
      final cachedBirthChart = await LocalCacheService.instance.getBirthChart(userId);
      if (cachedBirthChart != null) {
        // Check if cached data matches current user info
        final cachedBirthDate = cachedBirthChart['birthDate'] as String?;
        final cachedBirthTime = cachedBirthChart['birthTime'] as String?;
        final cachedLat = (cachedBirthChart['latitude'] as num?)?.toDouble();
        final cachedLng = (cachedBirthChart['longitude'] as num?)?.toDouble();
        
        // Format current birth date for comparison
        final currentBirthDateStr = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
        final currentBirthTime24 = birthTimeStr.contains(':') 
            ? birthTimeStr.split(' ')[0] // Already in 24-hour format
            : birthTimeStr; // Will be converted in sync method
        
        // If user info matches, use cached data (no sync needed)
        if (cachedBirthDate == currentBirthDateStr &&
            cachedBirthTime == currentBirthTime24 &&
            (cachedLat == null || (cachedLat - latitude).abs() < 0.001) &&
            (cachedLng == null || (cachedLng - longitude).abs() < 0.001)) {
          print('✅ Birth chart found in local cache and matches user info - no sync needed');
          return; // Skip sync entirely
        }
      }

      // Check Firebase if local cache doesn't exist or doesn't match
      // Birth Chart only changes when user updates personal info
      final birthChartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('birthChart')
          .get();

      bool needsSync = false;
      
      if (!birthChartDoc.exists) {
        needsSync = true;
        print('📡 Birth chart not found in Firebase - will sync');
      } else {
        // Check if user info matches cached data
        final data = birthChartDoc.data();
        final cachedBirthDate = data?['birthDate'] as String?;
        final cachedBirthTime = data?['birthTime'] as String?;
        final cachedLat = (data?['latitude'] as num?)?.toDouble();
        final cachedLng = (data?['longitude'] as num?)?.toDouble();
        
        // Format current birth date for comparison
        final currentBirthDateStr = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
        final currentBirthTime24 = birthTimeStr.contains(':') 
            ? birthTimeStr.split(' ')[0] // Already in 24-hour format
            : birthTimeStr; // Will be converted in sync method
        
        // Check if user info changed
        if (cachedBirthDate != currentBirthDateStr ||
            cachedBirthTime != currentBirthTime24 ||
            (cachedLat != null && (cachedLat - latitude).abs() > 0.001) ||
            (cachedLng != null && (cachedLng - longitude).abs() > 0.001)) {
          needsSync = true;
          print('📡 User info changed - will sync birth chart');
        } else {
          print('✅ Birth chart exists in Firebase and matches user info - no sync needed');
          // Cache to local for faster access next time
          await LocalCacheService.instance.saveBirthChart(userId, data!);
        }
      }

      if (needsSync) {
        print('📡 Syncing birth chart from FreeAstrologyAPI...');
        
        // Get coordinates if missing
        double lat = latitude;
        double lng = longitude;
        
        if (lat == 0.0 && lng == 0.0 && birthPlaceStr != null && birthPlaceStr.isNotEmpty) {
          // Try to get coordinates from birth place
          try {
            final locationService = LocationService();
            final locations = await locationService.searchAddress(birthPlaceStr);
            if (locations.isNotEmpty) {
              // LocationService returns Map<String, String> with 'lat' and 'lng' as strings
              final latStr = locations.first['lat'];
              final lngStr = locations.first['lng'];
              if (latStr != null && lngStr != null) {
                lat = double.tryParse(latStr) ?? 0.0;
                lng = double.tryParse(lngStr) ?? 0.0;
                
                // Update user profile with coordinates
                await _firestore.collection('users').doc(userId).update({
                  'birthLatitude': lat,
                  'birthLongitude': lng,
                });
              }
            }
          } catch (e) {
            print('⚠️ Error getting coordinates: $e');
          }
        }

        // Sync birth chart
        if (lat != 0.0 && lng != 0.0) {
          await _syncService.syncUserBirthChart(
            userId: userId,
            birthDate: birthDate,
            birthTime: birthTimeStr,
            latitude: lat,
            longitude: lng,
          );
        } else {
          print('⚠️ Missing coordinates, using default (0,0)');
          await _syncService.syncUserBirthChart(
            userId: userId,
            birthDate: birthDate,
            birthTime: birthTimeStr,
            latitude: 0.0,
            longitude: 0.0,
          );
        }

        // Sync characteristics (Sun, Moon, Ascendant)
        try {
          await _syncService.syncUserCharacteristics(userId: userId);
        } catch (e) {
          print('⚠️ Error syncing characteristics (non-critical): $e');
        }

        // Sync house cusps
        await _syncService.syncHouseCusps(
          userId: userId,
          date: birthDate,
          latitude: lat,
          longitude: lng,
        );

        // Sync daily horoscope if sun sign is available
        if (sunSign != null && sunSign.isNotEmpty && sunSign != 'Unknown') {
          await _syncService.syncDailyHoroscope(sunSign: sunSign);
          
          // Update tip of day based on horoscope
          try {
            final tipService = TipOfDayService.instance;
            await tipService.updateTipOfDay(date: DateTime.now(), sunSign: sunSign);
          } catch (e) {
            print('⚠️ Error updating tip of day: $e');
          }
        }

        print('✅ Astrology data synced successfully');
      } else {
        print('✅ Birth chart data is up to date');
      }
      
      // Update sync tracking
      _lastSyncedUserId = userId;
      _lastSyncTime = DateTime.now();
      _hasSyncedInSession = true; // Mark as synced in this session
    } catch (e) {
      print('❌ Error syncing astrology data on login: $e');
      // Don't throw - allow login to continue even if sync fails
    } finally {
      _isSyncing = false;
    }
  }

}


