import 'package:nidaa/prayer_time/data/model/hijri_date_model.dart';
import 'package:nidaa/prayer_time/data/model/night_times_model.dart';
import 'package:nidaa/prayer_time/data/model/prayer_model.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

class PrayerTimesModel extends PrayerTimes {
  const PrayerTimesModel({
    required super.prayer,
    required super.nightTimes,
    required super.hijriDate,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final timings = data['timings'] as Map<String, dynamic>;
    final hijri =
        (data['date'] as Map<String, dynamic>)['hijri'] as Map<String, dynamic>;

    return PrayerTimesModel(
      prayer: PrayerModel.fromJson(timings),
      nightTimes: NightTimesModel.fromJson(timings),
      hijriDate: HijriDateModel.fromJson(hijri),
    );
  }
}
