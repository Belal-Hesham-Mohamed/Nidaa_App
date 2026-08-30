class LocationPermissionException implements Exception {
  final String message;

  const LocationPermissionException(this.message);
}

class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);
}

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);
}