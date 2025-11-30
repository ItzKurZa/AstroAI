import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firestore_paths.dart';
import 'freeastrology_firebase_sync.dart';

/// Service to sync all astrology data from FreeAstrologyAPI to Firebase
/// 
/// Logic:
/// 1. Check Firestore first - if data exists and is fresh, skip API call
/// 2. Only call API if data doesn't exist or is older than 1 day
/// 3. Auto-refresh once per day
/// 4. Cache locally to reduce API calls
/// 5. Birth Chart: Only sync when user updates personal info
class AstroDataSyncService {
  AstroDataSyncService._();
  static final AstroDataSyncService instance = AstroDataSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FreeAstrologyFirebaseSync _syncService = FreeAstrologyFirebaseSync.instance;

  /// Initialize and sync all data on app start
  /// 
  /// This checks Firestore first, only calls API if needed
  Future<void> initializeAndSync() async {
    try {
      print('🚀 Initializing AstroDataSyncService...');
      
      // Check if we need to sync today's data
      await _ensureTodayData();
      
      print('✅ AstroDataSyncService initialized');
    } catch (e) {
      print('❌ Error initializing AstroDataSyncService: $e');
    }
  }

  /// Ensure today's data exists in Firestore
  /// Only calls API if data doesn't exist or is older than 1 day
  Future<void> _ensureTodayData() async {
    final today = DateTime.now();

    // Check planets_today
    final planetsDoc = await _firestore.doc(FirestorePaths.planetsTodayDoc(today)).get();
    if (!planetsDoc.exists || _needsRefresh(planetsDoc.data()?['updatedAt'])) {
      print('📡 Syncing planetary positions for today...');
      // This will be handled by DailyPlanetaryService
    }

    // Check you_today
    final youTodayDoc = await _firestore.doc(FirestorePaths.youTodayDoc(today)).get();
    if (!youTodayDoc.exists || _needsRefresh(youTodayDoc.data()?['updatedAt'])) {
      print('📡 Syncing you_today for today...');
      // This will be handled by YouTodayUpdater
    }

    // Check tip_of_day
    final tipDoc = await _firestore.doc(FirestorePaths.tipOfDayDoc(today)).get();
    if (!tipDoc.exists || _needsRefresh(tipDoc.data()?['updatedAt'])) {
      print('📡 Syncing tip_of_day for today...');
      // This will be handled by seeder or other service
    }
  }

  /// Check if data needs refresh (older than 1 day or different date)
  bool _needsRefresh(Timestamp? updatedAt) {
    if (updatedAt == null) return true;
    
    final now = DateTime.now();
    final dataDate = updatedAt.toDate();
    
    // Check if data is from a different date
    if (dataDate.year != now.year || 
        dataDate.month != now.month || 
        dataDate.day != now.day) {
      return true;
    }
    
    // Data is from today, no refresh needed
    return false;
  }

  /// Sync user's birth chart (only when user info changes)
  /// 
  /// This checks Firestore first - only calls API if user info changed
  Future<void> syncUserBirthChart({
    required String userId,
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    bool forceSync = false,
  }) async {
    await _syncService.syncUserBirthChart(
      userId: userId,
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
      forceSync: forceSync,
    );
  }

  /// Sync daily horoscope for a sign (auto-refresh once per day)
  Future<void> syncDailyHoroscope({
    required String sunSign,
    DateTime? date,
  }) async {
    await _syncService.syncDailyHoroscope(
      sunSign: sunSign,
      date: date,
    );
  }
}

