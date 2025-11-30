import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to manage local cache for app data
/// 
/// This service caches:
/// - User profile
/// - Home content (planets, you_today, tips)
/// - Planetary data
/// - Birth chart data
class LocalCacheService {
  static LocalCacheService? _instance;
  static LocalCacheService get instance {
    _instance ??= LocalCacheService._();
    return _instance!;
  }

  LocalCacheService._();

  static const String _keyPrefix = 'astroai_cache_';
  static const String _keyUserProfile = '${_keyPrefix}user_profile';
  static const String _keyHomeContent = '${_keyPrefix}home_content_';
  static const String _keyPlanetaryData = '${_keyPrefix}planetary_data_';
  static const String _keyBirthChart = '${_keyPrefix}birth_chart';
  static const String _keyCharacteristics = '${_keyPrefix}characteristics_';
  static const String _keyCacheTimestamp = '${_keyPrefix}timestamp_';

  /// Encode Map to handle Timestamp objects for JSON serialization
  Map<String, dynamic> _encodeMap(Map<String, dynamic> data) {
    final encodedMap = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Timestamp) {
        encodedMap[key] = {
          '_type': 'timestamp',
          'seconds': value.seconds,
          'nanoseconds': value.nanoseconds,
        };
      } else if (value is Map<String, dynamic>) {
        encodedMap[key] = _encodeMap(value);
      } else if (value is List) {
        encodedMap[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _encodeMap(item);
          } else if (item is Timestamp) {
            return {
              '_type': 'timestamp',
              'seconds': item.seconds,
              'nanoseconds': item.nanoseconds,
            };
          }
          return item;
        }).toList();
      } else {
        encodedMap[key] = value;
      }
    });
    return encodedMap;
  }

  /// Decode Map to restore Timestamp objects from JSON
  Map<String, dynamic> _decodeMap(Map<String, dynamic> data) {
    final decodedMap = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Map<String, dynamic> && value['_type'] == 'timestamp') {
        decodedMap[key] = Timestamp(
          value['seconds'] as int,
          value['nanoseconds'] as int,
        );
      } else if (value is Map<String, dynamic>) {
        decodedMap[key] = _decodeMap(value);
      } else if (value is List) {
        decodedMap[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            if (item['_type'] == 'timestamp') {
              return Timestamp(
                item['seconds'] as int,
                item['nanoseconds'] as int,
              );
            }
            return _decodeMap(item);
          }
          return item;
        }).toList();
      } else {
        decodedMap[key] = value;
      }
    });
    return decodedMap;
  }

  /// Save user profile to cache
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _encodeMap(userData);
      await prefs.setString(_keyUserProfile, jsonEncode(encoded));
      await prefs.setString('${_keyCacheTimestamp}user_profile', 
          DateTime.now().toIso8601String());
      print('✅ Cached user profile');
    } catch (e) {
      print('❌ Error caching user profile: $e');
    }
  }

  /// Clear user profile cache
  Future<void> clearUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserProfile);
      await prefs.remove('${_keyCacheTimestamp}user_profile');
      print('✅ Cleared user profile cache');
    } catch (e) {
      print('❌ Error clearing user profile cache: $e');
    }
  }

  /// Get user profile from cache
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_keyUserProfile);
      if (cached == null) return null;
      
      final timestamp = prefs.getString('${_keyCacheTimestamp}user_profile');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);
        // Cache valid for 1 hour
        if (age.inHours > 1) {
          print('⚠️ User profile cache expired');
          return null;
        }
      }
      
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      return _decodeMap(decoded);
    } catch (e) {
      print('❌ Error reading user profile cache: $e');
      return null;
    }
  }

  /// Save home content for a specific date
  Future<void> saveHomeContent(String dateId, Map<String, dynamic> content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _encodeMap(content);
      await prefs.setString('$_keyHomeContent$dateId', jsonEncode(encoded));
      await prefs.setString('${_keyCacheTimestamp}home_$dateId', 
          DateTime.now().toIso8601String());
      print('✅ Cached home content for $dateId');
    } catch (e) {
      print('❌ Error caching home content: $e');
    }
  }

  /// Get home content from cache
  /// Also fixes old data that might have Pluto.png instead of Pluton.png
  Future<Map<String, dynamic>?> getHomeContent(String dateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_keyHomeContent$dateId');
      if (cached == null) return null;
      
      final timestamp = prefs.getString('${_keyCacheTimestamp}home_$dateId');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);
        // Cache valid for 30 minutes
        if (age.inMinutes > 30) {
          print('⚠️ Home content cache expired for $dateId');
          return null;
        }
      }
      
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      final data = _decodeMap(decoded);
      
      // Fix old cached data that might have Pluto.png instead of Pluton.png
      final planets = data['planets'] as Map<String, dynamic>?;
      if (planets != null) {
        final cards = planets['cards'] as List<dynamic>?;
        if (cards != null) {
          bool needsFix = false;
          final fixedCards = cards.map((card) {
            if (card is Map<String, dynamic>) {
              final imageUrl = card['imageUrl'] as String?;
              if (imageUrl != null && imageUrl.contains('Pluto.png')) {
                needsFix = true;
                return {
                  ...card,
                  'imageUrl': imageUrl.replaceAll('Pluto.png', 'Pluton.png'),
                };
              }
            }
            return card;
          }).toList();
          
          if (needsFix) {
            // Update cache with fixed data
            final fixedData = {
              ...data,
              'planets': {
                ...planets,
                'cards': fixedCards,
              },
            };
            await saveHomeContent(dateId, fixedData);
            return fixedData;
          }
        }
      }
      
      return data;
    } catch (e) {
      print('❌ Error reading home content cache: $e');
      return null;
    }
  }

  /// Save planetary data for a specific date
  Future<void> savePlanetaryData(String dateId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _encodeMap(data);
      await prefs.setString('$_keyPlanetaryData$dateId', jsonEncode(encoded));
      await prefs.setString('${_keyCacheTimestamp}planetary_$dateId', 
          DateTime.now().toIso8601String());
      print('✅ Cached planetary data for $dateId');
    } catch (e) {
      print('❌ Error caching planetary data: $e');
    }
  }

  /// Get planetary data from cache
          /// Also fixes old data that might have Pluto.png instead of Pluton.png
  Future<Map<String, dynamic>?> getPlanetaryData(String dateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_keyPlanetaryData$dateId');
      if (cached == null) return null;
      
      final timestamp = prefs.getString('${_keyCacheTimestamp}planetary_$dateId');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);
        // Cache valid for 24 hours (planetary data changes daily)
        if (age.inHours > 24) {
          print('⚠️ Planetary data cache expired for $dateId');
          return null;
        }
      }
      
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
              final data = _decodeMap(decoded);
              
              // Fix old cached data that might have Pluto.png instead of Pluton.png
              final cards = data['cards'] as List<dynamic>?;
              if (cards != null) {
                bool needsFix = false;
                final fixedCards = cards.map((card) {
                  if (card is Map<String, dynamic>) {
                    final imageUrl = card['imageUrl'] as String?;
                    if (imageUrl != null && imageUrl.contains('Pluto.png')) {
                      needsFix = true;
                      return {
                        ...card,
                        'imageUrl': imageUrl.replaceAll('Pluto.png', 'Pluton.png'),
                      };
                    }
                  }
                  return card;
                }).toList();
                
                if (needsFix) {
                  // Update cache with fixed data
                  final fixedData = {
                    ...data,
                    'cards': fixedCards,
                  };
                  await savePlanetaryData(dateId, fixedData);
                  return fixedData;
                }
              }
              
              return data;
    } catch (e) {
      print('❌ Error reading planetary data cache: $e');
      return null;
    }
  }

  /// Save birth chart data
  Future<void> saveBirthChart(String userId, Map<String, dynamic> birthChart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _encodeMap(birthChart);
      await prefs.setString('$_keyBirthChart$userId', jsonEncode(encoded));
      await prefs.setString('${_keyCacheTimestamp}birth_chart_$userId', 
          DateTime.now().toIso8601String());
      print('✅ Cached birth chart for user $userId');
    } catch (e) {
      print('❌ Error caching birth chart: $e');
    }
  }

  /// Get birth chart from cache
  Future<Map<String, dynamic>?> getBirthChart(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_keyBirthChart$userId');
      if (cached == null) return null;
      
      final timestamp = prefs.getString('${_keyCacheTimestamp}birth_chart_$userId');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);
        // Cache valid for 7 days (birth chart doesn't change)
        if (age.inDays > 7) {
          print('⚠️ Birth chart cache expired for user $userId');
          return null;
        }
      }
      
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      return _decodeMap(decoded);
    } catch (e) {
      print('❌ Error reading birth chart cache: $e');
      return null;
    }
  }

  /// Clear all cache for a user
  Future<void> clearUserCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }
      
      print('✅ Cleared all cache for user $userId');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Save characteristics data
  Future<void> saveCharacteristics(String userId, List<Map<String, dynamic>> characteristics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyCharacteristics$userId', jsonEncode(characteristics));
      await prefs.setString('${_keyCacheTimestamp}characteristics_$userId', 
          DateTime.now().toIso8601String());
      print('✅ Cached characteristics for user $userId');
    } catch (e) {
      print('❌ Error caching characteristics: $e');
    }
  }

  /// Get characteristics from cache
  Future<List<Map<String, dynamic>>?> getCharacteristics(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_keyCharacteristics$userId');
      if (cached == null) return null;
      
      final timestamp = prefs.getString('${_keyCacheTimestamp}characteristics_$userId');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);
        // Cache valid for 7 days (characteristics don't change unless user updates birth info)
        if (age.inDays > 7) {
          print('⚠️ Characteristics cache expired for user $userId');
          return null;
        }
      }
      
      final decoded = jsonDecode(cached) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error reading characteristics cache: $e');
      return null;
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();
      
      for (final key in keys) {
        if (key.startsWith('${_keyCacheTimestamp}')) {
          final timestampStr = prefs.getString(key);
          if (timestampStr != null) {
            try {
              final cacheTime = DateTime.parse(timestampStr);
              final age = now.difference(cacheTime);
              
              // Remove if older than 7 days
              if (age.inDays > 7) {
                final dataKey = key.replaceFirst('${_keyCacheTimestamp}', '');
                await prefs.remove(key);
                await prefs.remove('$_keyPrefix$dataKey');
              }
            } catch (e) {
              // Invalid timestamp, remove it
              await prefs.remove(key);
            }
          }
        }
      }
      
      print('✅ Cleared expired cache entries');
    } catch (e) {
      print('❌ Error clearing expired cache: $e');
    }
  }
}

