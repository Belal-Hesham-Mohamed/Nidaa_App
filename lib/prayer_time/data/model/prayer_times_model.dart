import 'package:nidaa/prayer_time/data/model/hijri_date_model.dart';
import 'package:nidaa/prayer_time/data/model/night_times_model.dart';
import 'package:nidaa/prayer_time/data/model/prayer_model.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

class PrayerTimesModel extends PrayerTimes {
  const PrayerTimesModel({
    required super.date,
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
      date: _gregorianDate(data),
      prayer: PrayerModel.fromJson(timings),
      nightTimes: NightTimesModel.fromJson(timings),
      hijriDate: HijriDateModel.fromJson(hijri),
    );
  }

  static List<PrayerTimesModel> fromCalendarJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? const [];
    return data.whereType<Map<String, dynamic>>().map((day) {
      final timings = day['timings'] as Map<String, dynamic>;
      final date = day['date'] as Map<String, dynamic>;
      return PrayerTimesModel(
        date: _gregorianDate(day),
        prayer: PrayerModel.fromJson(timings),
        nightTimes: NightTimesModel.fromJson(timings),
        hijriDate: HijriDateModel.fromJson(
          date['hijri'] as Map<String, dynamic>,
        ),
      );
    }).toList();
  }

  static String _gregorianDate(Map<String, dynamic> data) {
    final date = data['date'] as Map<String, dynamic>?;
    final gregorian = date?['gregorian'];
    if (gregorian is Map<String, dynamic>) {
      return gregorian['date'].toString();
    }
    return date?['readable']?.toString() ?? '';
  }
}
