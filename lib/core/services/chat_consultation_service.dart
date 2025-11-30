import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_service.dart';
import '../data/models/birth_chart_model.dart';

/// Service for real-time astrological consultation chat with Gemini AI
/// Each user has their own chat session with personalized system instruction
class ChatConsultationService {
  final FirebaseFirestore _firestore;
  final GeminiService _geminiService;
  
  // Store sessions per user ID to support multiple users chatting simultaneously
  final Map<String, ChatSession> _userSessions = {};

  ChatConsultationService({
    FirebaseFirestore? firestore,
    GeminiService? geminiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _geminiService = geminiService ?? GeminiService.instance;

  /// Start a new consultation session for a user
  /// Each user gets their own session with personalized system instruction
  /// Note: Does NOT send a welcome message automatically - only initializes the session
  Future<void> startSession({
    required String userId,
    required String userName,
    required String sunSign,
    required String moonSign,
    required String ascendantSign,
  }) async {
    // Fetch user data to get birth date and time
    final userData = await _getUserData(userId);
    final birthDate = userData['birthDate'] as String?;
    final birthTime = userData['birthTime'] as String?;
    final birthPlace = userData['birthPlace'] as String?;
    
    // Fetch birth chart data from Firebase
    final birthChartData = await _getBirthChartData(userId);
    
    // Create a new session for this user (or replace existing one)
    final session = _geminiService.startChatSession(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendantSign: ascendantSign,
      userName: userName,
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
      birthChartData: birthChartData,
    );
    
    // Store session for this user
    _userSessions[userId] = session;

    // DO NOT send welcome message automatically
    // Welcome message will be sent only when user sends their first message
  }

  /// Send a message and get AI response
  /// Uses the user's own session to maintain conversation context
  /// If this is the first message, sends a welcome greeting first
  /// [saveUserMessage] - if false, don't save user message to Firestore (useful when message is already saved separately)
  Future<String> sendMessage(String userId, String message, {bool saveUserMessage = true}) async {
    // Get or create session for this user
    ChatSession? session = _userSessions[userId];
    
    // Check if this is the first message (no messages in Firestore yet)
    final messagesSnapshot = await _firestore
        .collection('chat_threads')
        .doc(userId)
        .collection('messages')
        .limit(1)
        .get();
    final isFirstMessage = messagesSnapshot.docs.isEmpty;
    
    if (session == null) {
      // Session doesn't exist, create a new one
      final userData = await _getUserData(userId);
      await startSession(
        userId: userId,
        userName: userData['displayName'] ?? 'Seeker',
        sunSign: userData['sunSign'] ?? 'Unknown',
        moonSign: userData['moonSign'] ?? 'Unknown',
        ascendantSign: userData['ascendantSign'] ?? 'Unknown',
      );
      session = _userSessions[userId]!;
    }
    
    // If this is the first message, send a welcome greeting first
    if (isFirstMessage) {
      final userData = await _getUserData(userId);
      final userName = userData['displayName'] ?? 'Seeker';
      final sunSign = userData['sunSign'] ?? 'Unknown';
      final moonSign = userData['moonSign'] ?? 'Unknown';
      final ascendantSign = userData['ascendantSign'] ?? 'Unknown';
      
      final greeting = 'Welcome, dear $userName! ✨ I sense the cosmic energies surrounding you today. '
          'As a $sunSign with $moonSign Moon and $ascendantSign rising, you carry a unique '
          'celestial blueprint. How may I illuminate your path today? Would you like to explore '
          'your love life, career prospects, or perhaps understand the current planetary transits '
          'affecting you?';
      
      // Save welcome message to Firestore
      await _saveMessage(userId, 'advisor', greeting);
    }

    // Save user message (only if saveUserMessage is true)
    if (saveUserMessage) {
      await _saveMessage(userId, 'user', message);
    }

    // Get AI response using this user's session (already cleaned by GeminiService)
    // Simple approach: just send message, no key switching
    final response = await _geminiService.sendChatMessage(
      session,
      message,
    );

    // Save cleaned AI response
    await _saveMessage(userId, 'advisor', response);

    return response;
  }

  /// Get chat history for a user
  /// Each user has their own chat thread: chat_threads/{userId}/messages
  Stream<List<Map<String, dynamic>>> getChatHistory(String userId) {
    return _firestore
        .collection('chat_threads')
        .doc(userId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'sender': data['sender'],
                'text': data['text'],
                'createdAt': data['createdAt'],
              };
            }).toList());
  }

  /// Clear chat session for a specific user (useful for logout or reset)
  void clearSession(String userId) {
    _userSessions.remove(userId);
  }

  /// Clear all chat sessions (useful for cleanup)
  void clearAllSessions() {
    _userSessions.clear();
  }

  /// Save a message to Firestore
  /// Each user has their own chat thread: chat_threads/{userId}/messages
  Future<void> _saveMessage(String userId, String sender, String text) async {
    // Ensure chat thread exists
    final threadRef = _firestore.collection('chat_threads').doc(userId);
    await threadRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'title': 'Advisor AI',
      'type': 'advisor',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Save message to user's chat thread
    await threadRef.collection('messages').add({
      'sender': sender,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  /// Get birth chart data from Firebase
  Future<Map<String, dynamic>?> _getBirthChartData(String userId) async {
    try {
      final birthChartDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('astrology')
          .doc('birthChart')
          .get();

      if (!birthChartDoc.exists) {
        return null;
      }

      final data = birthChartDoc.data()!;
      
      // Parse to BirthChartModel for easier access
      try {
        final birthChart = BirthChartModel.fromMap(data);
        
        // Format planetary positions for Gemini
        final planetsInfo = birthChart.planets.map((planet) {
          return '${planet.planetName}: ${planet.degreesInSign.toStringAsFixed(2)}° in ${planet.zodiacSign}';
        }).join(', ');
        
        // Format houses
        final housesInfo = birthChart.houses.map((house) {
          return 'House ${house.houseNumber}: ${house.degreesInSign.toStringAsFixed(2)}° in ${house.zodiacSign}';
        }).join(', ');
        
        return {
          'planets': planetsInfo,
          'houses': housesInfo,
          'ascendant': '${birthChart.ascendant.degreesInSign.toStringAsFixed(2)}° in ${birthChart.ascendant.zodiacSign}',
          'midheaven': '${birthChart.midheaven.degreesInSign.toStringAsFixed(2)}° in ${birthChart.midheaven.zodiacSign}',
          'raw': data, // Keep raw data for detailed queries
        };
      } catch (e) {
        print('Error parsing birth chart: $e');
        return data; // Return raw data if parsing fails
      }
    } catch (e) {
      print('Error fetching birth chart: $e');
      return null;
    }
  }

  /// Clear chat history for a user
  /// Each user has their own chat thread: chat_threads/{userId}/messages
  Future<void> clearHistory(String userId) async {
    final messages = await _firestore
        .collection('chat_threads')
        .doc(userId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Clear the session for this user
    clearSession(userId);
  }

  /// Get specific reading types
  Future<String> getReading(String userId, ReadingType type) async {
    String prompt;
    switch (type) {
      case ReadingType.love:
        prompt = 'Give me a detailed love and relationship reading for today. '
            'What do the stars say about my romantic life?';
        break;
      case ReadingType.career:
        prompt = 'Provide a detailed career and professional reading. '
            'What opportunities and challenges do the planets reveal?';
        break;
      case ReadingType.health:
        prompt = 'Share insights about my health and well-being based on current transits. '
            'What should I focus on for optimal wellness?';
        break;
      case ReadingType.finance:
        prompt = 'Give me a financial outlook reading. '
            'What do the celestial bodies indicate about money and abundance?';
        break;
      case ReadingType.general:
        prompt = 'Provide a comprehensive general reading for today. '
            'Cover all aspects of my life that the stars are highlighting.';
        break;
    }

    return sendMessage(userId, prompt);
  }

  /// Ask a specific question
  Future<String> askQuestion(String userId, String question) async {
    final prompt = 'Based on my birth chart and current planetary positions, $question';
    return sendMessage(userId, prompt);
  }

  /// Start a compatibility session with another user
  /// Creates a separate session for compatibility analysis
  /// Note: Does NOT send a welcome message automatically - only initializes the session
  Future<void> startCompatibilitySession({
    required String userId,
    required String userName,
    required String sunSign,
    required String moonSign,
    required String ascendantSign,
    required String targetUserId,
    required String targetUserName,
    required String targetSunSign,
    required String targetMoonSign,
    required String targetAscendantSign,
  }) async {
    // Fetch birth chart data for both users
    final userBirthChart = await _getBirthChartData(userId);
    final targetBirthChart = await _getBirthChartData(targetUserId);
    
    // Format birth chart info for Gemini
    String userChartInfo = _formatBirthChartInfo(
      userName, sunSign, moonSign, ascendantSign, userBirthChart,
    );
    String targetChartInfo = _formatBirthChartInfo(
      targetUserName, targetSunSign, targetMoonSign, targetAscendantSign, targetBirthChart,
    );
    
    // Create system instruction for compatibility analysis
    final systemInstruction = '''
You are Advisor, a mystical and wise AI astrologer specializing in relationship compatibility analysis.

You are analyzing the compatibility between two people:
- User A ($userName): $sunSign Sun, $moonSign Moon, $ascendantSign Rising
- User B ($targetUserName): $targetSunSign Sun, $targetMoonSign Moon, $targetAscendantSign Rising

$userChartInfo

$targetChartInfo

Your task is to:
1. Compare and analyze the birth charts of both users
2. Assess friendship compatibility (0-100%)
3. Analyze the psychological profile of User B ($targetUserName)
4. Provide insights on emotional connection, communication style, and potential harmony/challenges
5. Give practical advice for building a strong friendship

Language:
- IMPORTANT: Always respond in the same language that the user uses to ask questions
- If the user asks in Vietnamese, respond in Vietnamese
- If the user asks in English, respond in English
- If the user asks in any other language, respond in that same language
- Match the user's language style and formality level

Always respond in a warm, mystical, and encouraging tone. Use astrological terminology naturally.
Do not use markdown formatting or special characters like ***.
''';
    
    // Get user data for birth date/time/place
    final userData = await _getUserData(userId);
    final birthDate = userData['birthDate'] as String?;
    final birthTime = userData['birthTime'] as String?;
    final birthPlace = userData['birthPlace'] as String?;
    
    // Start new chat session with compatibility context
    // Use a special key for compatibility sessions to keep them separate from regular chat
    final compatibilitySessionKey = '${userId}_compatibility_$targetUserId';
    final session = _geminiService.startChatSession(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendantSign: ascendantSign,
      userName: userName,
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
      birthChartData: userBirthChart,
      systemInstruction: systemInstruction,
    );
    
    // Store compatibility session separately
    _userSessions[compatibilitySessionKey] = session;

    // DO NOT send welcome message automatically
    // Welcome message will be sent only when user sends their first message
  }
  
  /// Send a message in compatibility session and get AI response
  /// If this is the first message, sends a welcome greeting first
  Future<String> sendCompatibilityMessage(
    String userId,
    String targetUserId,
    String message,
  ) async {
    final compatibilitySessionKey = '${userId}_compatibility_$targetUserId';
    ChatSession? session = _userSessions[compatibilitySessionKey];
    
    if (session == null) {
      // Need to recreate the session - this shouldn't happen if startCompatibilitySession was called
      // But handle it gracefully
      throw Exception('Compatibility session not initialized. Call startCompatibilitySession first.');
    }
    
    // Check if this is the first message (no messages in Firestore yet)
    final messagesSnapshot = await _firestore
        .collection('chat_threads')
        .doc(userId)
        .collection('messages')
        .limit(1)
        .get();
    final isFirstMessage = messagesSnapshot.docs.isEmpty;
    
    // If this is the first message, send a welcome greeting first
    if (isFirstMessage) {
      // Get user data for greeting
      final userData = await _getUserData(userId);
      final userName = userData['displayName'] ?? 'Seeker';
      final sunSign = userData['sunSign'] ?? 'Unknown';
      
      // Get target user data
      final targetUserData = await _getUserData(targetUserId);
      final targetUserName = targetUserData['displayName'] ?? 'This person';
      final targetSunSign = targetUserData['sunSign'] ?? 'Unknown';
      
    final greeting = 'Greetings, $userName! ✨ I sense you\'re curious about your connection with $targetUserName. '
        'Let me analyze the cosmic dance between your $sunSign energy and their $targetSunSign essence. '
        'What would you like to know about your compatibility? You can ask me: '
        '"How compatible are we?", "What is their personality like?", or "Should we be friends?"';

      // Save welcome message to Firestore
    await _saveMessage(userId, 'advisor', greeting);
    }
    
    // Save user message
    await _saveMessage(userId, 'user', message);
    
    // Get AI response
    final response = await _geminiService.sendChatMessage(session, message);
    
    // Save AI response
    await _saveMessage(userId, 'advisor', response);

    return response;
  }

  /// Format birth chart info for Gemini prompt
  String _formatBirthChartInfo(
    String name,
    String sunSign,
    String moonSign,
    String ascendantSign,
    Map<String, dynamic>? birthChartData,
  ) {
    String info = '''
$name's Astrological Profile:
- Sun Sign: $sunSign
- Moon Sign: $moonSign
- Ascendant/Rising: $ascendantSign
''';
    
    if (birthChartData != null) {
      if (birthChartData['planets'] != null) {
        info += '\nPlanetary Positions: ${birthChartData['planets']}';
      }
      if (birthChartData['houses'] != null) {
        info += '\nHouse Cusps: ${birthChartData['houses']}';
      }
    }
    
    return info;
  }

  /// Get compatibility reading with another sign
  Future<String> getCompatibility(
    String userId,
    String otherSunSign,
    String otherMoonSign,
  ) async {
    final prompt = '''
I want to know about my compatibility with someone who has:
- Sun Sign: $otherSunSign
- Moon Sign: $otherMoonSign

Please analyze our cosmic compatibility in terms of:
1. Emotional connection
2. Communication style
3. Long-term potential
4. Areas of harmony
5. Potential challenges
''';
    return sendMessage(userId, prompt);
  }
}

/// Types of astrological readings available
enum ReadingType {
  love,
  career,
  health,
  finance,
  general,
}
