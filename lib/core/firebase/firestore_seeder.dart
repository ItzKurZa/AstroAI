import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/daily_planetary_service.dart';
import '../services/you_today_updater.dart';
import '../services/tip_of_day_service.dart';
import '../services/astrological_event_generator.dart';
import 'firestore_paths.dart';

class FirestoreSeeder {
  FirestoreSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  /// Seed general content (not user-specific)
  /// This should only be called once, not per user
  /// Note: No longer seeding matches, horoscopes, characteristics - using real data only
  Future<void> ensureGeneralContent() async {
    await Future.wait([
      _ensurePlanets(),
      _ensureYouToday(),
      _ensureTipOfDay(),
      _ensureAstrologicalEvents(),
    ]);
  }

  /// Seed user-specific content (only called after proper signup)
  Future<void> ensureUserContent(String userId) async {
    await Future.wait([
      _ensureNotificationPrefs(userId),
      _ensureChatThread(userId),
    ]);
  }

  Future<void> _ensureNotificationPrefs(String userId) async {
    // Create default notification preferences (real data, not sample)
    final doc = _firestore.doc(FirestorePaths.notificationPrefsDoc(userId));
    if (!(await doc.get()).exists) {
      await doc.set({
        'dailyDigest': true,
        'friendAdded': true,
        'friendAccepted': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _ensurePlanets() async {
    // Use DailyPlanetaryService to calculate real planetary positions from FreeAstrologyAPI
    // This ensures data is always accurate and from API
    try {
      final planetaryService = DailyPlanetaryService.instance;
      await planetaryService.calculateAndSaveDailyPlanets(
        date: DateTime.now(),
        forceRecalculate: false,
      );
    } catch (e) {
      print('⚠️ Error generating planetary data: $e');
      // Don't throw - data will be generated when needed
    }
  }

  Future<void> _ensureYouToday() async {
    // Use YouTodayUpdater to generate real data from FreeAstrologyAPI
    try {
      final youTodayUpdater = YouTodayUpdater.instance;
      await youTodayUpdater.updateYouToday(date: DateTime.now());
    } catch (e) {
      print('⚠️ Error generating you_today: $e');
      // Don't throw - this is non-critical initialization
    }
  }

  Future<void> _ensureTipOfDay() async {
    // Use TipOfDayService to generate real data from FreeAstrologyAPI
    try {
      final tipService = TipOfDayService.instance;
      await tipService.getTipOfDay(date: DateTime.now());
    } catch (e) {
      print('⚠️ Error generating tip of day: $e');
      // Don't throw - this is non-critical initialization
    }
  }


  Future<void> _ensureChatThread(String userId) async {
    // Create Advisor AI chat thread
    final threadDoc = _firestore.doc(FirestorePaths.chatThread(userId));
    if (!(await threadDoc.get()).exists) {
      await threadDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'title': 'Advisor AI',
        'type': 'advisor',
      });
    }
  }

  Future<void> _ensureAstrologicalEvents() async {
    // Generate astrological events automatically
    try {
      final generator = AstrologicalEventGenerator.instance;
      await generator.generateEventsForNext90Days();
      print('✅ Astrological events generated successfully');
    } catch (e) {
      print('⚠️ Error generating astrological events: $e');
      // Don't throw - events generation is non-critical
    }
  }
}

