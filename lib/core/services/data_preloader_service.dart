import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/firestore_paths.dart';
import 'local_cache_service.dart';
import 'daily_planetary_service.dart';
import 'you_today_updater.dart';
import 'astrology_sync_on_login.dart';

/// Service to preload all app data when user logs in or signs up
/// 
/// This service:
/// 1. Preloads user profile
/// 2. Preloads today's home content (planets, you_today, tips)
/// 3. Preloads planetary data for today and next 7 days
/// 4. Preloads birth chart data
/// 5. Ensures all data is cached locally for fast access
class DataPreloaderService {
  static DataPreloaderService? _instance;
  static DataPreloaderService get instance {
    _instance ??= DataPreloaderService._();
    return _instance!;
  }

  DataPreloaderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalCacheService _cache = LocalCacheService.instance;
  final DailyPlanetaryService _planetaryService = DailyPlanetaryService.instance;
  final YouTodayUpdater _youTodayUpdater = YouTodayUpdater.instance;

  /// Preload all data for a user after login/signup
  /// 
  /// This runs in background and doesn't block UI
  Future<void> preloadAllData(String userId) async {
    try {
      print('🚀 Starting data preload for user: $userId');
      
      // Run all preload operations in parallel for speed
      await Future.wait([
        _preloadUserProfile(userId),
        _preloadHomeContent(userId),
        _preloadPlanetaryData(),
        _preloadBirthChart(userId),
      ], eagerError: false); // Don't fail all if one fails
      
      print('✅ Data preload completed for user: $userId');
    } catch (e) {
      print('❌ Error during data preload: $e');
      // Don't throw - preload is non-critical
    }
  }

  /// Preload user profile
  Future<void> _preloadUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.doc(FirestorePaths.user(userId)).get();
      if (userDoc.exists && userDoc.data() != null) {
        await _cache.saveUserProfile(userDoc.data()!);
        print('✅ Preloaded user profile');
      }
    } catch (e) {
      print('⚠️ Error preloading user profile: $e');
    }
  }

  /// Preload home content (planets, you_today, tips) for today and next 7 days
  Future<void> _preloadHomeContent(String userId) async {
    try {
      final today = DateTime.now();
      final dates = List.generate(8, (i) => today.add(Duration(days: i)));
      
      // Preload for today and next 7 days
      for (final date in dates) {
        final dateId = FirestorePaths.dateId(date);
        
        // Load all documents in parallel
        final results = await Future.wait([
          _firestore.doc(FirestorePaths.planetsTodayDoc(date)).get(),
          _firestore.doc(FirestorePaths.youTodayDoc(date)).get(),
          _firestore.doc(FirestorePaths.tipOfDayDoc(date)).get(),
        ], eagerError: false);
        
        final planetsDoc = results[0];
        final sectionsDoc = results[1];
        final tipDoc = results[2];
        
        // Combine into home content
        final homeContent = {
          'planets': planetsDoc.exists ? planetsDoc.data() : null,
          'sections': sectionsDoc.exists ? sectionsDoc.data() : null,
          'tip': tipDoc.exists ? tipDoc.data() : null,
        };
        
        await _cache.saveHomeContent(dateId, homeContent);
        
        // If data doesn't exist, trigger calculation in background
        if (!planetsDoc.exists || !sectionsDoc.exists) {
          _ensureDataExists(date, userId).catchError((e) {
            print('⚠️ Error ensuring data exists for $dateId: $e');
          });
        }
      }
      
      print('✅ Preloaded home content for 8 days');
    } catch (e) {
      print('⚠️ Error preloading home content: $e');
    }
  }

  /// Ensure data exists for a date (calculate if needed)
  Future<void> _ensureDataExists(DateTime date, String userId) async {
    try {
      // Ensure planetary data exists
      await _planetaryService.getPlanetaryData(date);
      
      // Ensure you_today is updated
      await _youTodayUpdater.updateYouToday(date: date, userId: userId);
      
      // Re-cache after calculation
      final dateId = FirestorePaths.dateId(date);
      final results = await Future.wait([
        _firestore.doc(FirestorePaths.planetsTodayDoc(date)).get(),
        _firestore.doc(FirestorePaths.youTodayDoc(date)).get(),
        _firestore.doc(FirestorePaths.tipOfDayDoc(date)).get(),
      ], eagerError: false);
      
      final planetsDoc = results[0];
      final sectionsDoc = results[1];
      final tipDoc = results[2];
      
      final homeContent = {
        'planets': planetsDoc.exists ? planetsDoc.data() : null,
        'sections': sectionsDoc.exists ? sectionsDoc.data() : null,
        'tip': tipDoc.exists ? tipDoc.data() : null,
      };
      
      await _cache.saveHomeContent(dateId, homeContent);
    } catch (e) {
      print('⚠️ Error ensuring data exists: $e');
    }
  }

  /// Preload planetary data for today and next 7 days
  Future<void> _preloadPlanetaryData() async {
    try {
      final today = DateTime.now();
      final dates = List.generate(8, (i) => today.add(Duration(days: i)));
      
      // Preload planetary data for all dates
      for (final date in dates) {
        final dateId = FirestorePaths.dateId(date);
        
        // Get planetary data (will calculate if not exists)
        final planetaryData = await _planetaryService.getPlanetaryData(date);
        
        if (planetaryData.isNotEmpty) {
          await _cache.savePlanetaryData(dateId, planetaryData);
        }
      }
      
      print('✅ Preloaded planetary data for 8 days');
    } catch (e) {
      print('⚠️ Error preloading planetary data: $e');
    }
  }

  /// Preload birth chart data
  Future<void> _preloadBirthChart(String userId) async {
    try {
      // First, sync astrology data if needed
      await AstrologySyncOnLogin.instance.syncAfterLogin();
      
      // Then load birth chart from Firestore
      final birthChartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('birthChart')
          .get();
      
      if (birthChartDoc.exists && birthChartDoc.data() != null) {
        await _cache.saveBirthChart(userId, birthChartDoc.data()!);
        print('✅ Preloaded birth chart');
      }
    } catch (e) {
      print('⚠️ Error preloading birth chart: $e');
    }
  }

  /// Clear all cached data (useful for logout)
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('astroai_cache_')) {
          await prefs.remove(key);
        }
      }
      
      print('✅ Cleared all cached data');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}

