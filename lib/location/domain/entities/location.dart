import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String country;
  final String city;
  final bool isManual;
  const Location({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.city,
    this.isManual = false,
  });

  @override
  List<Object?> get props => [latitude, longitude, city, country, isManual];
}
