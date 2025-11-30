import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_key_manager.dart';

/// Singleton service for Gemini AI interactions with automatic key rotation
class GeminiService {
  static GeminiService? _instance;
  GenerativeModel? _model;
  GenerativeModel? _chatModel;
  final GeminiKeyManager _keyManager = GeminiKeyManager.instance;

  // Store system instructions per session
  final Map<ChatSession, String> _sessionInstructions = {};

  GeminiService._();

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Initialize the Gemini models with key rotation support
  void initialize() {
    // Load all available keys
    _keyManager.loadKeys();
    
    // Get current key and initialize models
    _reinitializeModels();
  }

  /// Reinitialize models with current or new key
  void _reinitializeModels() {
    final apiKey = _keyManager.getCurrentKey();
    
    if (apiKey.isEmpty) {
      throw Exception('No valid Gemini API key available');
    }

    // Model for generating daily horoscopes (more creative)
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );

    // Model for chat consultations (more balanced)
    // Note: systemInstruction will be set dynamically per chat session
    _chatModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024, // Increased for detailed responses when requested
      ),
      // No system instruction here - will be set per session
    );
  }

  GenerativeModel get model {
    if (_model == null) {
      throw Exception('GeminiService not initialized. Call initialize() first.');
    }
    return _model!;
  }

  GenerativeModel get chatModel {
    if (_chatModel == null) {
      throw Exception('GeminiService not initialized. Call initialize() first.');
    }
    return _chatModel!;
  }

  /// Generate text from a simple prompt (for you_today descriptions)
  Future<String> generateText(String prompt) async {
      try {
        if (_model == null) {
          throw Exception('GeminiService not initialized. Call initialize() first.');
        }
        
        // Generate content with proper error handling
        final response = await _model!.generateContent([Content.text(prompt)]);
        
        // Extract text directly from candidates to avoid Content format errors
        String text = '';
        
        // Try to extract from candidates first (more reliable)
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.content.parts.isNotEmpty) {
            for (final part in candidate.content.parts) {
              if (part is TextPart) {
                text += part.text;
              }
            }
          }
        }
        
        // Fallback to response.text if candidates extraction failed
        if (text.isEmpty) {
          try {
            text = response.text ?? '';
          } catch (e) {
            // If response.text also fails, log and continue
            print('⚠️ Both candidates and response.text failed: $e');
          }
        }
        
        if (text.isEmpty) {
          throw Exception('Empty response from Gemini API');
        }
        
        // Clean the response
        return _cleanGeminiResponse(text);
      } catch (e) {
        final errorStr = e.toString();
        
      // Check if it's the Content format error
          if (errorStr.contains('Unhandled format for Content') || 
              errorStr.contains('role: model')) {
        print('⚠️ Content format error: $e');
            return '';
        }
        
      print('❌ Error generating text: $e');
        rethrow;
      }
  }

  /// Generate daily horoscope content for a user
  Future<Map<String, dynamic>> generateDailyHoroscope({
    required String sunSign,
    required String moonSign,
    required String ascendantSign,
    required DateTime birthDate,
    required String birthPlace,
    required DateTime targetDate,
  }) async {
    final prompt = '''
Generate a personalized daily horoscope for $targetDate for someone with:
- Sun Sign: $sunSign
- Moon Sign: $moonSign
- Ascendant/Rising Sign: $ascendantSign
- Birth Date: $birthDate
- Birth Place: $birthPlace

Provide the response in this exact JSON format:
{
  "overview": "A 2-3 sentence daily overview",
  "health": {
    "rating": 1-5,
    "description": "Health advice for today",
    "planets": ["Planet1 in Sign", "Planet2 in Sign"]
  },
  "finance": {
    "rating": 1-5,
    "description": "Financial outlook for today",
    "planets": ["Planet1 in Sign", "Planet2 in Sign"]
  },
  "relationship": {
    "rating": 1-5,
    "description": "Relationship guidance for today",
    "planets": ["Planet1 in Sign", "Planet2 in Sign"]
  },
  "career": {
    "rating": 1-5,
    "description": "Career insights for today",
    "planets": ["Planet1 in Sign", "Planet2 in Sign"]
  },
  "luckyNumbers": [1, 2, 3],
  "luckyColor": "Color name",
  "tip": "A wise quote or advice for the day",
  "planetaryPositions": [
    {"planet": "Sun", "sign": "Sign", "degrees": "XX°XX'XX\\""},
    {"planet": "Moon", "sign": "Sign", "degrees": "XX°XX'XX\\""},
    {"planet": "Mercury", "sign": "Sign", "degrees": "XX°XX'XX\\""},
    {"planet": "Venus", "sign": "Sign", "degrees": "XX°XX'XX\\""},
    {"planet": "Mars", "sign": "Sign", "degrees": "XX°XX'XX\\""}
  ]
}

Only respond with valid JSON, no additional text.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      
      // Extract text from candidates to avoid Content format errors
      String text = '';
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        if (candidate.content.parts.isNotEmpty) {
          for (final part in candidate.content.parts) {
            if (part is TextPart) {
              text += part.text;
            }
          }
        }
      }
      
      // Fallback to response.text if needed
      if (text.isEmpty) {
        try {
          text = response.text ?? '{}';
        } catch (e) {
          text = '{}';
        }
      }
      
      // Clean up the response - remove markdown code blocks if present
      String cleanJson = text.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      
      // Parse JSON
      return _parseJson(cleanJson.trim());
    } catch (e) {
      print('❌ Error generating horoscope: $e');
      return _getDefaultHoroscope();
    }
  }

  /// Start a chat session for consultation
  /// Creates a new model with dynamic system instruction based on user data
  ChatSession startChatSession({
    required String sunSign,
    required String moonSign,
    required String ascendantSign,
    required String userName,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    Map<String, dynamic>? birthChartData,
    String? systemInstruction,
  }) {
    // Build comprehensive system instruction with user-specific data
    String instruction = systemInstruction ?? '''
You are Advisor, a mystical and wise AI astrologer. You provide personalized astrological readings, 
horoscope interpretations, and spiritual guidance based on the user's birth chart data.

User Profile:
- Name: $userName
- Birth Date: ${birthDate ?? 'Not provided'}
- Birth Time: ${birthTime ?? 'Not provided'}
- Birth Place: ${birthPlace ?? 'Not provided'}
- Sun Sign: $sunSign
- Moon Sign: $moonSign
- Ascendant: $ascendantSign
''';

    // Add detailed birth chart information if available
    if (birthChartData != null) {
      instruction += '\n\nDetailed Birth Chart (from FreeAstrologyAPI):\n';
      
      if (birthChartData['planets'] != null) {
        instruction += 'Planetary Positions:\n${birthChartData['planets']}\n\n';
      }
      
      if (birthChartData['houses'] != null) {
        instruction += 'House Cusps:\n${birthChartData['houses']}\n\n';
      }
      
      if (birthChartData['ascendant'] != null) {
        instruction += 'Ascendant (1st House): ${birthChartData['ascendant']}\n';
      }
      
      if (birthChartData['midheaven'] != null) {
        instruction += 'Midheaven (10th House): ${birthChartData['midheaven']}\n';
      }
      
      instruction += '\nUse this detailed birth chart data to provide accurate and personalized astrological readings. ';
      instruction += 'Reference specific planetary positions, house placements, and aspects when giving advice.';
    }

    instruction += '''

Your personality:
- Warm, empathetic, and insightful
- Speak with mystical wisdom but remain grounded
- Use astrological terminology naturally
- Provide actionable advice based on planetary positions
- Be encouraging and positive while being honest

Response Style:
- IMPORTANT: Keep responses CONCISE and to the point (2-4 sentences for simple questions, 4-6 sentences for complex topics)
- Be direct and clear - avoid unnecessary elaboration
- Focus on the most important insights first
- If the user asks a simple question, give a simple answer
- Only provide detailed explanations when specifically asked

Language Rules (STRICTLY ENFORCE):
- You MUST detect the language of the user's message and respond ONLY in that same language
- If the user writes in English, you MUST respond in English - NEVER use Vietnamese or any other language
- If the user writes in Vietnamese, you MUST respond in Vietnamese - NEVER use English or any other language
- NEVER mix languages in your response
- NEVER start with greetings in a different language than the user's message
- Example: If user says "I want to learn about...", respond in English starting with "Hello" or "Greetings", NOT "Chào" or "Xin chào"
- Match the user's language style and formality level exactly

When providing readings:
- Reference specific planetary positions and house placements when relevant
- Use the exact degrees and signs provided in the birth chart data
- Connect cosmic events to daily life with practical examples
- Keep explanations brief but meaningful
- Avoid repeating information unnecessarily

The birth chart data you receive is calculated using professional astrological methods from FreeAstrologyAPI, 
so you can trust its accuracy and provide accurate, personalized interpretations.

Greet the user warmly and offer astrological guidance.
''';

    // Create a new model with dynamic system instruction for this session
    // Always get the key directly from key manager (no cache)
    final apiKey = _keyManager.getCurrentKey();
    print('🔑 Creating new chat session with API key: ${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}');
    
    // Create model directly with current key (no caching)
    // Use full model name as per API documentation
    final sessionModel = GenerativeModel(
      model: 'gemini-2.0-flash', // SDK will handle the full path
      apiKey: apiKey, // Direct from key manager, no cache
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024, // Increased for detailed responses when requested
      ),
    );
    
    // Verify key is valid by checking it's not empty
    if (apiKey.isEmpty || apiKey.length < 20) {
      throw Exception('Invalid API key format');
    }

    // Start chat - system instruction will be prepended to first message
    final chat = sessionModel.startChat();
    
    // Store instruction for this session to use in first message
    _sessionInstructions[chat] = instruction;
    
    return chat;
  }

  /// Send a message in chat consultation
  /// Note: Chat sessions are tied to a specific key, so retry requires recreating the session
  Future<String> sendChatMessage(ChatSession session, String message, {int maxRetries = 2}) async {
    // Check if this is the first message and we have system instruction
    final systemInstruction = _sessionInstructions[session];
    
    // Detect user's language and add language enforcement
    final trimmedMessage = message.trim();
    final messageSample = trimmedMessage.length > 50 
        ? trimmedMessage.substring(0, 50) 
        : trimmedMessage;
    final isEnglish = RegExp(r'^[a-zA-Z]').hasMatch(messageSample);
    final languageEnforcement = isEnglish 
        ? '\n\nIMPORTANT: The user wrote in English. You MUST respond in English only. Do NOT use Vietnamese or any other language. Start with Hello or Greetings, NOT Chao or Xin chao.'
        : '\n\nIMPORTANT: The user wrote in Vietnamese. You MUST respond in Vietnamese only.';
    
    final messageToSend = systemInstruction != null
        ? '$systemInstruction$languageEnforcement\n\nUser: $message'
        : '$languageEnforcement\n\nUser: $message';
    
    // Remove instruction after first use
    if (systemInstruction != null) {
      _sessionInstructions.remove(session);
    }
    
      // Try to send message and get response
      GenerateContentResponse response;
      try {
      response = await session.sendMessage(Content.text(messageToSend));
      } catch (sendError) {
        final errorStr = sendError.toString();
        // If it's Content format error during send, return helpful message
        if (errorStr.contains('Unhandled format for Content') || 
            errorStr.contains('role: model')) {
          print('⚠️ Content format error during sendMessage: $sendError');
          return 'I apologize, but there was a communication issue. Please try sending your message again.';
        }
      
        rethrow;
      }
    
    try {
      
      // Extract text from candidates to avoid Content format errors
      String rawText = '';
      try {
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.content.parts.isNotEmpty) {
            for (final part in candidate.content.parts) {
              if (part is TextPart) {
                rawText += part.text;
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ Error extracting from candidates: $e');
      }
      
      // Fallback to response.text if needed
      if (rawText.isEmpty) {
        try {
          rawText = response.text ?? 'The stars are unclear at this moment. Please try again.';
        } catch (e) {
          print('⚠️ Error accessing response.text: $e');
          rawText = 'The stars are unclear at this moment. Please try again.';
        }
      }
      
      if (rawText.isEmpty) {
        return 'I apologize, but I could not generate a response. Please try again.';
      }
      
      // Clean the response to remove markdown formatting and special characters
      return _cleanGeminiResponse(rawText);
    } catch (e) {
      final errorStr = e.toString();
      
      // Check if it's Content format error
      if (errorStr.contains('Unhandled format for Content') || 
          errorStr.contains('role: model')) {
        print('⚠️ Content format error in chat: $e');
        // Return a helpful message instead of generic error
        return 'I apologize, but there was a technical issue processing your message. Please try rephrasing your question or try again in a moment.';
      }
      
      // For errors, return error message
      print('❌ Error in chat: $e');
      if (errorStr.contains('403') || errorStr.contains('forbidden') || errorStr.contains('leaked')) {
        return 'I apologize, but there was an authentication issue with the AI service. Please try again in a moment, or contact support if the problem persists.';
      }
      return 'I apologize, but the cosmic connection seems disrupted. Please try again.';
    }
  }

  /// Clean Gemini response by removing markdown formatting and special characters
  String _cleanGeminiResponse(String text) {
    if (text.isEmpty) return text;
    
    String cleaned = text;
    
    // Remove markdown bold/italic formatting (***, **, *)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*\*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\*\*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!\*)\*(?!\*)'), '');
    
    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`[^`]*`'), '');
    
    // Remove markdown headers
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remove markdown links but keep text
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    
    // Remove markdown lists
    cleaned = cleaned.replaceAll(RegExp(r'^[\*\-\+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    
    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]+'), ' ');
    
    // Trim whitespace
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      // Simple JSON parsing - in production use dart:convert
      // For now return a structured response
      return {
        'overview': 'The stars align favorably for you today.',
        'health': {
          'rating': 4,
          'description': 'Good energy levels today.',
          'planets': ['Sun in Aries', 'Moon in Taurus'],
        },
        'finance': {
          'rating': 3,
          'description': 'Steady financial outlook.',
          'planets': ['Mercury in Capricorn', 'Jupiter in Taurus'],
        },
        'relationship': {
          'rating': 4,
          'description': 'Harmonious connections today.',
          'planets': ['Venus in Scorpio', 'Mars in Sagittarius'],
        },
        'career': {
          'rating': 5,
          'description': 'Excellent day for career advancement.',
          'planets': ['Saturn in Pisces', 'Jupiter in Taurus'],
        },
        'luckyNumbers': [3, 7, 12],
        'luckyColor': 'Purple',
        'tip': 'Trust your intuition today.',
        'raw': jsonString,
      };
    } catch (e) {
      return _getDefaultHoroscope();
    }
  }

  Map<String, dynamic> _getDefaultHoroscope() {
    return {
      'overview': 'Today brings opportunities for growth and reflection.',
      'health': {
        'rating': 3,
        'description': 'Take time to rest and recharge.',
        'planets': ['Sun in current sign', 'Moon transiting'],
      },
      'finance': {
        'rating': 3,
        'description': 'Be mindful of spending.',
        'planets': ['Mercury aspect', 'Venus position'],
      },
      'relationship': {
        'rating': 3,
        'description': 'Open communication is key.',
        'planets': ['Venus aspect', 'Mars position'],
      },
      'career': {
        'rating': 3,
        'description': 'Focus on your goals.',
        'planets': ['Saturn aspect', 'Jupiter position'],
      },
      'luckyNumbers': [1, 5, 9],
      'luckyColor': 'Blue',
      'tip': 'Every day is a new beginning.',
    };
  }
}
