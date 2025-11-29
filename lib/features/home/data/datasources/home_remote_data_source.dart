import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../../../../core/services/daily_planetary_service.dart';
import '../../../../core/services/you_today_updater.dart';
import '../../../../core/services/tip_of_day_service.dart';
import '../../../../core/services/local_cache_service.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../models/home_content_model.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  final DailyPlanetaryService _planetaryService = DailyPlanetaryService.instance;
  final LocalCacheService _cache = LocalCacheService.instance;

  /// Fetch content for a specific date
  /// Loads from Firestore and caches for next time
  Future<HomeContentModel> fetchContent(String userId, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateId = FirestorePaths.dateId(targetDate);
    
    // Load all data in parallel (fast - just reading from Firestore)
    final results = await Future.wait([
      _firestore.doc(FirestorePaths.planetsTodayDoc(targetDate)).get(),
      _firestore.doc(FirestorePaths.youTodayDoc(targetDate)).get(),
      _firestore.doc(FirestorePaths.tipOfDayDoc(targetDate)).get(),
      _firestore.doc(FirestorePaths.user(userId)).get(),
    ]);

    final planetsDoc = results[0];
    final sectionsDoc = results[1];
    final tipDoc = results[2];
    final userDoc = results[3];

    final user = UserProfileModel.fromDoc(userDoc);

    // Cache the loaded data for next time (always update cache)
    final homeContent = {
      'planets': planetsDoc.exists ? planetsDoc.data() : null,
      'sections': sectionsDoc.exists ? sectionsDoc.data() : null,
      'tip': tipDoc.exists ? tipDoc.data() : null,
    };
    await _cache.saveHomeContent(dateId, homeContent);
    if (userDoc.exists && userDoc.data() != null) {
      await _cache.saveUserProfile(userDoc.data()!);
    }

    // Check if data exists, if not, trigger background update (non-blocking)
    final hasPlanetaryData = planetsDoc.exists && 
        planetsDoc.data() != null && 
        (planetsDoc.data()?['cards'] as List?)?.isNotEmpty == true;
    final hasYouTodayData = sectionsDoc.exists && 
        sectionsDoc.data() != null &&
        (sectionsDoc.data()?['sections'] as List?)?.isNotEmpty == true;
    final hasTipData = tipDoc.exists && 
        tipDoc.data() != null &&
        (tipDoc.data()?['text'] as String?)?.isNotEmpty == true;

    // If data is missing, trigger background update (don't wait - non-blocking)
    // All data will be generated from FreeAstrologyAPI, not sample data
    if (!hasPlanetaryData || !hasYouTodayData || !hasTipData) {
      // Run updates in background, don't block UI
      _updateDataInBackground(targetDate, userId).catchError((e) {
        print('⚠️ Background data update error: $e');
      });
    }

    // Return data immediately
    return HomeContentModel.fromSnapshots(
      planetsDoc: planetsDoc,
      sectionsDoc: sectionsDoc,
      tipDoc: tipDoc,
      user: user,
    );
  }

  /// Update planetary and you_today data in background (non-blocking)
  Future<void> _updateDataInBackground(DateTime date, String userId) async {
    try {
      // Ensure planetary data exists (will calculate from FreeAstrologyAPI if needed)
      await _planetaryService.getPlanetaryData(date);
      
      // Ensure you_today is updated (uses FreeAstrologyAPI horoscope data)
      final youTodayUpdater = YouTodayUpdater.instance;
      await youTodayUpdater.updateYouToday(date: date, userId: userId);
      
      // Ensure tip of day is updated (uses FreeAstrologyAPI horoscope data)
      try {
        // Get user's sun sign for personalized tip
        final userDoc = await _firestore.doc(FirestorePaths.user(userId)).get();
        final sunSign = userDoc.data()?['sunSign'] as String?;
        final tipService = TipOfDayService.instance;
        await tipService.updateTipOfDay(date: date, sunSign: sunSign);
      } catch (e) {
        print('⚠️ Error updating tip of day in background: $e');
      }
    } catch (e) {
      print('❌ Error in background data update: $e');
      // Don't rethrow - this is background work
    }
  }

  Future<UserProfileModel> fetchUser(String userId) async {
    final doc = await _firestore.doc(FirestorePaths.user(userId)).get();
    return UserProfileModel.fromDoc(doc);
  }
}

