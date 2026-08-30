class PrayerTimesApiConstants {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  static String timingsByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) {
    return '$baseUrl/timings/$date'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=5';
  }

  static String timingsByCity({
    required String city,
    required String country,
    required String date,
  }) {
    return '$baseUrl/timingsByCity/$date'
        '?city=$city'
        '&country=$country'
        '&method=5';
  }
}
