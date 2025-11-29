import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Manages multiple Gemini API keys with automatic rotation on errors
class GeminiKeyManager {
  static GeminiKeyManager? _instance;
  static GeminiKeyManager get instance {
    _instance ??= GeminiKeyManager._();
    return _instance!;
  }

  GeminiKeyManager._();

  List<String> _keys = [];
  int _currentKeyIndex = 0;
  Set<int> _failedKeyIndices = {}; // Track keys that have failed

  /// Load all available keys from .env file
  void loadKeys() {
    _keys.clear();
    _failedKeyIndices.clear();
    _currentKeyIndex = 0;

    // Try to load keys from GEMINI_KEY_1 to GEMINI_KEY_10
    for (int i = 1; i <= 10; i++) {
      final key = dotenv.env['GEMINI_KEY_$i'];
      if (key != null && key.isNotEmpty && key.trim().isNotEmpty) {
        _keys.add(key.trim());
      }
    }

    // Fallback to GEMINI_API_KEY if no numbered keys found
    if (_keys.isEmpty) {
      final fallbackKey = dotenv.env['GEMINI_API_KEY'];
      if (fallbackKey != null && fallbackKey.isNotEmpty && fallbackKey.trim().isNotEmpty) {
        _keys.add(fallbackKey.trim());
      }
    }

    if (_keys.isEmpty) {
      throw Exception('No Gemini API keys found in .env file. Please add GEMINI_KEY_1, GEMINI_KEY_2, etc.');
    }

    print('✅ Loaded ${_keys.length} Gemini API key(s)');
  }

  /// Get the current active key
  String getCurrentKey() {
    if (_keys.isEmpty) {
      loadKeys();
    }
    
    if (_keys.isEmpty) {
      throw Exception('No Gemini API keys available');
    }

    // If current key has failed, try to get next available key
    if (_failedKeyIndices.contains(_currentKeyIndex)) {
      return getNextAvailableKey();
    }

    return _keys[_currentKeyIndex];
  }

  /// Get the next available key (skip failed ones)
  String getNextAvailableKey() {
    if (_keys.isEmpty) {
      loadKeys();
    }

    if (_keys.isEmpty) {
      throw Exception('No Gemini API keys available');
    }

    // If all keys have failed, reset and try again
    if (_failedKeyIndices.length >= _keys.length) {
      print('⚠️ All keys have failed, resetting and trying again...');
      _failedKeyIndices.clear();
      _currentKeyIndex = 0;
    }

    // Find next available key
    int attempts = 0;
    while (attempts < _keys.length) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _keys.length;
      
      if (!_failedKeyIndices.contains(_currentKeyIndex)) {
        print('🔄 Switched to key ${_currentKeyIndex + 1}/${_keys.length}');
        return _keys[_currentKeyIndex];
      }
      
      attempts++;
    }

    // Should not reach here, but fallback
    _currentKeyIndex = 0;
    return _keys[_currentKeyIndex];
  }

  /// Mark current key as failed and switch to next
  void markCurrentKeyAsFailed(String? errorMessage) {
    if (_keys.isEmpty) return;

    final error = errorMessage?.toLowerCase() ?? '';
    final isQuotaError = error.contains('429') || 
                        error.contains('quota') || 
                        error.contains('rate limit') ||
                        error.contains('too many requests');
    
    final isAuthError = error.contains('403') || 
                       error.contains('401') ||
                       error.contains('unauthorized') ||
                       error.contains('forbidden');

    // Only mark as failed if it's a quota/auth error (not temporary network issues)
    if (isQuotaError || isAuthError) {
      if (!_failedKeyIndices.contains(_currentKeyIndex)) {
        _failedKeyIndices.add(_currentKeyIndex);
        print('❌ Key ${_currentKeyIndex + 1} marked as failed: ${isQuotaError ? "Quota exceeded" : "Auth error"}');
      }
    }
  }

  /// Check if we should retry with a different key based on error
  bool shouldRetryWithNewKey(dynamic error) {
    if (_keys.length <= 1) return false; // Only one key, can't switch

    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('429') || 
           errorStr.contains('quota') || 
           errorStr.contains('rate limit') ||
           errorStr.contains('too many requests') ||
           errorStr.contains('403') ||
           errorStr.contains('401');
  }

  /// Reset all failed keys (useful for periodic reset)
  void resetFailedKeys() {
    _failedKeyIndices.clear();
    print('🔄 Reset all failed keys');
  }

  /// Get status information
  Map<String, dynamic> getStatus() {
    return {
      'totalKeys': _keys.length,
      'currentKeyIndex': _currentKeyIndex + 1,
      'failedKeys': _failedKeyIndices.length,
      'availableKeys': _keys.length - _failedKeyIndices.length,
    };
  }
}

