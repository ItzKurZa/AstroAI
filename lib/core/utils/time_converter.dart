/// Utility for converting time formats
class TimeConverter {
  /// Convert time from 12-hour format (HH:MM AM/PM) to 24-hour format (HH:mm)
  /// 
  /// Examples:
  /// - "12:00 AM" -> "00:00"
  /// - "01:30 PM" -> "13:30"
  /// - "12:00 PM" -> "12:00"
  /// - "11:59 PM" -> "23:59"
  /// 
  /// Also handles formats like:
  /// - "12:00AM" (no space)
  /// - "1:30 PM" (single digit hour)
  /// - "Unknown" -> returns "12:00" as default
  static String convertTo24Hour(String time12Hour) {
    if (time12Hour.isEmpty || time12Hour.toLowerCase() == 'unknown') {
      return '12:00'; // Default to noon if unknown
    }

    // Normalize the input
    String normalized = time12Hour.trim().toUpperCase();
    
    // Remove spaces around AM/PM
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    // Check if it's already in 24-hour format (contains only digits and colon)
    if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(normalized)) {
      return normalized; // Already 24-hour format
    }

    // Extract hour, minute, and period
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)').firstMatch(normalized);
    if (match == null) {
      // Try without space
      final match2 = RegExp(r'(\d{1,2}):(\d{2})(AM|PM)').firstMatch(normalized);
      if (match2 == null) {
        print('⚠️ Could not parse time format: $time12Hour, using default 12:00');
        return '12:00';
      }
      return _convertMatch(match2);
    }
    
    return _convertMatch(match);
  }

  static String _convertMatch(RegExpMatch match) {
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = match.group(3)!;

    // Convert to 24-hour format
    if (period == 'AM') {
      if (hour == 12) {
        hour = 0; // 12:XX AM becomes 00:XX
      }
    } else if (period == 'PM') {
      if (hour != 12) {
        hour += 12; // 1:XX PM becomes 13:XX, but 12:XX PM stays 12:XX
      }
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

