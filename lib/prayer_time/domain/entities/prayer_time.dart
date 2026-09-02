import 'package:equatable/equatable.dart';

class Prayer extends Equatable {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;

  const Prayer({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
  });

  @override
  List<Object?> get props => [fajr, sunrise, dhuhr, asr, sunset, maghrib, isha];
}

class NightTimes extends Equatable {
  final String midnight;
  final String firstThird;
  final String lastThird;

  const NightTimes({
    required this.midnight,
    required this.firstThird,
    required this.lastThird,
  });

  @override
  List<Object?> get props => [midnight, firstThird, lastThird];
}

class HijriDate extends Equatable {
  final String day;
  final String month;
  final String year;

  const HijriDate({required this.day, required this.month, required this.year});

  @override
  List<Object?> get props => [day, month, year];
}

class PrayerTimes extends Equatable {
  final String date;
  final Prayer prayer;
  final NightTimes nightTimes;
  final HijriDate hijriDate;

  const PrayerTimes({
    this.date = '',
    required this.prayer,
    required this.nightTimes,
    required this.hijriDate,
  });

  @override
  List<Object?> get props => [date, prayer, nightTimes, hijriDate];
}
