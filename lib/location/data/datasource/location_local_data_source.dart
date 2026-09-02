import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:nidaa/core/error/exception.dart';
import 'package:nidaa/location/data/model/location_model.dart';

abstract class LocationLocalDataSource {
  Future<LocationModel> getCurrentLocation();
  LocationModel? getSavedLocation();
  Future<void> saveLocation(LocationModel location);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  static const String _boxName = 'locationBox';
  static const String _key = 'location';

  Box<LocationModel> get _box => Hive.box<LocationModel>(_boxName);

  @override
  LocationModel? getSavedLocation() => _box.get(_key);

  @override
  Future<void> saveLocation(LocationModel location) => _box.put(_key, location);

  @override
  Future<LocationModel> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceException('Location service is disabled');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw const LocationPermissionException(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException('Location permission denied');
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final geocoder = Geocoding();
      final placemarks = await geocoder.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isEmpty ? null : placemarks.first;

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        country: place?.country ?? '',
        city: place?.locality ?? '',
      );
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException(e.toString());
    }
  }
}
