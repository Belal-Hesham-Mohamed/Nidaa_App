
import '../../domain/entities/location.dart';
import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 0)
class LocationModel {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String country;

  @HiveField(3)
  final String city;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.city,
  });

  Location toEntity() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      country: country,
      city: city,
    );
  }
}