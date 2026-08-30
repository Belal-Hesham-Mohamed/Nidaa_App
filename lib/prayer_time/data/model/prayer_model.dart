import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

class PrayerModel extends Prayer {
  const PrayerModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.sunset,
    required super.maghrib,
    required super.isha,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      fajr: json['Fajr'].toString(),
      sunrise: json['Sunrise'].toString(),
      dhuhr: json['Dhuhr'].toString(),
      asr: json['Asr'].toString(),
      sunset: json['Sunset'].toString(),
      maghrib: json['Maghrib'].toString(),
      isha: json['Isha'].toString(),
    );
  }
}
