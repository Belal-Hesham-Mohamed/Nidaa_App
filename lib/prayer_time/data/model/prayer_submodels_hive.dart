import 'package:hive/hive.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

part 'prayer_submodels_hive.g.dart';

@HiveType(typeId: 2)
class PrayerHiveModel extends Prayer {
  const PrayerHiveModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.sunset,
    required super.maghrib,
    required super.isha,
  });
}

@HiveType(typeId: 3)
class NightTimesHiveModel extends NightTimes {
  const NightTimesHiveModel({
    required super.midnight,
    required super.firstThird,
    required super.lastThird,
  });
}

@HiveType(typeId: 4)
class HijriDateHiveModel extends HijriDate {
  const HijriDateHiveModel({
    required super.day,
    required super.month,
    required super.year,
  });
}
