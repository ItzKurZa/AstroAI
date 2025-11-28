import 'package:intl/intl.dart';

class FirestorePaths {
  static const String _users = 'users';
  static const String _matches = 'matches';
  static const String _horoscopes = 'horoscopes';
  static const String _planetsToday = 'planets_today';
  static const String _youToday = 'you_today';
  static const String _tips = 'tips';
  static const String _characteristics = 'characteristics';
  static const String _notificationPrefs = 'notification_prefs';
  static const String _chatThreads = 'chat_threads';
  static const String seedDateId = '2023-12-13';

  static String dateId([DateTime? date]) {
    return DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
  }

  static String user(String uid) => '$_users/$uid';

  static String planetsTodayDoc([DateTime? date]) =>
      '$_planetsToday/${dateId(date)}';

  static String youTodayDoc([DateTime? date]) =>
      '$_youToday/${dateId(date)}';

  static String tipOfDayDoc([DateTime? date]) => '$_tips/${dateId(date)}';

  static String matchesCollection() => _matches;

  static String horoscopesCollection() => _horoscopes;

  static String characteristicsCollection() => _characteristics;

  static String notificationPrefsDoc(String uid) =>
      '$_notificationPrefs/$uid';

  static String chatThread(String uid) => '$_chatThreads/$uid';
}

