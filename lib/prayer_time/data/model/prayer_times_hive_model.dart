import 'package:hive/hive.dart';
import 'package:nidaa/prayer_time/data/model/prayer_submodels_hive.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

part 'prayer_times_hive_model.g.dart';

@HiveType(typeId: 1)
class PrayerTimesHiveModel {
  @HiveField(0)
  final PrayerHiveModel prayer;

  @HiveField(1)
  final NightTimesHiveModel nightTimes;

  @HiveField(2)
  final HijriDateHiveModel hijriDate;

  const PrayerTimesHiveModel({
    required this.prayer,
    required this.nightTimes,
    required this.hijriDate,
  });

  factory PrayerTimesHiveModel.fromEntity(PrayerTimes prayerTimes) {
    return PrayerTimesHiveModel(
      prayer: PrayerHiveModel(
        fajr: prayerTimes.prayer.fajr,
        sunrise: prayerTimes.prayer.sunrise,
        dhuhr: prayerTimes.prayer.dhuhr,
        asr: prayerTimes.prayer.asr,
        sunset: prayerTimes.prayer.sunset,
        maghrib: prayerTimes.prayer.maghrib,
        isha: prayerTimes.prayer.isha,
      ),
      nightTimes: NightTimesHiveModel(
        midnight: prayerTimes.nightTimes.midnight,
        firstThird: prayerTimes.nightTimes.firstThird,
        lastThird: prayerTimes.nightTimes.lastThird,
      ),
      hijriDate: HijriDateHiveModel(
        day: prayerTimes.hijriDate.day,
        month: prayerTimes.hijriDate.month,
        year: prayerTimes.hijriDate.year,
      ),
    );
  }

  PrayerTimes toEntity() {
    return PrayerTimes(
      prayer: prayer,
      nightTimes: nightTimes,
      hijriDate: hijriDate,
    );
  }
}
