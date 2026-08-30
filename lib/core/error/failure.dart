abstract class Failure {
  final String massage;
  const Failure(this.massage);
}

class PermissionFailure extends Failure {
  const PermissionFailure() : super('Location permission denied');
}

class LocationServiceFailure extends Failure {
  const LocationServiceFailure() : super('Location service is disabled');
}

class LocationFailure extends Failure {
  const LocationFailure() : super('Failed to get current location');
}

class PrayerTimesNetworkFailure extends Failure {
  const PrayerTimesNetworkFailure()
    : super('Unable to connect to the prayer times service');
}

class PrayerTimesServerFailure extends Failure {
  const PrayerTimesServerFailure()
    : super('The prayer times service returned an error');
}

class PrayerTimesFailure extends Failure {
  const PrayerTimesFailure() : super('Failed to get prayer times');
}
