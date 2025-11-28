import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';
import 'sample_data.dart';

class FirestoreSeeder {
  FirestoreSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> ensureInitialContent(String userId) async {
    await Future.wait([
      _ensureUser(userId),
      _ensureNotificationPrefs(userId),
      _ensurePlanets(),
      _ensureYouToday(),
      _ensureTipOfDay(),
      _ensureHoroscopes(),
      _ensureMatches(),
      _ensureCharacteristics(),
      _ensureChatThread(userId),
    ]);
  }

  Future<void> _ensureUser(String userId) async {
    final doc = _firestore.doc(FirestorePaths.user(userId));
    await doc.set(sampleUserProfile, SetOptions(merge: true));
  }

  Future<void> _ensureNotificationPrefs(String userId) async {
    final doc = _firestore.doc(FirestorePaths.notificationPrefsDoc(userId));
    await doc.set(sampleNotificationPrefs, SetOptions(merge: true));
  }

  Future<void> _ensurePlanets() async {
    final doc = _firestore.doc(FirestorePaths.planetsTodayDoc());
    await doc.set(samplePlanetsDoc, SetOptions(merge: true));
  }

  Future<void> _ensureYouToday() async {
    final doc = _firestore.doc(FirestorePaths.youTodayDoc());
    await doc.set(sampleYouTodayDoc, SetOptions(merge: true));
  }

  Future<void> _ensureTipOfDay() async {
    final doc = _firestore.doc(FirestorePaths.tipOfDayDoc());
    await doc.set(sampleTipDoc, SetOptions(merge: true));
  }

  Future<void> _ensureHoroscopes() async {
    await _syncCollection(
      _firestore.collection(FirestorePaths.horoscopesCollection()),
      sampleHoroscopeArticles,
    );
  }

  Future<void> _ensureMatches() async {
    await _syncCollection(
      _firestore.collection(FirestorePaths.matchesCollection()),
      sampleMatchProfiles,
    );
  }

  Future<void> _ensureCharacteristics() async {
    await _syncCollection(
      _firestore.collection(FirestorePaths.characteristicsCollection()),
      sampleCharacteristics,
    );
  }

  Future<void> _ensureChatThread(String userId) async {
    final threadDoc = _firestore.doc(FirestorePaths.chatThread(userId));
    if (!(await threadDoc.get()).exists) {
      await threadDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'title': 'Advisor AI',
      });
    }
    final messagesCollection = threadDoc.collection('messages');
    final hasMessages = await messagesCollection.limit(1).get();
    if (hasMessages.docs.isEmpty) {
      for (final message in sampleChatMessages) {
        await messagesCollection.add(message);
      }
    }
  }

  Future<void> _syncCollection(
    CollectionReference<Map<String, dynamic>> collection,
    List<Map<String, dynamic>> samples,
  ) async {
    final idsToKeep = samples.map((entry) => entry['id'] as String).toSet();
    final existing = await collection.get();
    final batch = _firestore.batch();
    for (final doc in existing.docs) {
      if (!idsToKeep.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }
    for (final entry in samples) {
      final id = entry['id'] as String;
      batch.set(
        collection.doc(id),
        entry,
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}

