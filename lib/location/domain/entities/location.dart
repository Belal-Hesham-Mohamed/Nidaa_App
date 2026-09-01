import 'dart:io';

import 'package:equatable/equatable.dart';

class Location extends Equatable{
final double latitude;
final double longitude;
final String country;
final String city;
const Location({
  required this.latitude,
  required this.longitude,
   required this.country,
    required this.city
});

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    city,
    country
  ];
}