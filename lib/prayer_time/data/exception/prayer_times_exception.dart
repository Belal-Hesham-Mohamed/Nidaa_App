class PrayerTimesNetworkException implements Exception {
  final String message;

  const PrayerTimesNetworkException(this.message);
}

class PrayerTimesServerException implements Exception {
  final String message;

  const PrayerTimesServerException(this.message);
}

class PrayerTimesException implements Exception {
  final String message;

  const PrayerTimesException(this.message);
}
