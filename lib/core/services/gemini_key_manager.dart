import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple manager for single Gemini API key
class GeminiKeyManager {
  static GeminiKeyManager? _instance;
  static GeminiKeyManager get instance {
    _instance ??= GeminiKeyManager._();
    return _instance!;
  }

  GeminiKeyManager._();

  String? _apiKey;

  /// Load API key from .env file
  void loadKeys() {
    // Only load GEMINI_API_KEY
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key != null && key.isNotEmpty && key.trim().isNotEmpty) {
      _apiKey = key.trim();
      print('✅ Loaded Gemini API key');
    } else {
      throw Exception('No GEMINI_API_KEY found in .env file. Please add GEMINI_API_KEY.');
    }
  }

  /// Get the API key
  /// Always loads fresh from .env (no caching)
  String getCurrentKey() {
    // Always reload key from .env to ensure we have the latest key
    if (_apiKey == null) {
      loadKeys();
    }
    
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('No Gemini API key available');
    }

    return _apiKey!;
  }

  /// Get status information (for compatibility)
  Map<String, dynamic> getStatus() {
    return {
      'totalKeys': 1,
      'currentKeyIndex': 1,
      'failedKeys': 0,
      'availableKeys': 1,
    };
  }
}

