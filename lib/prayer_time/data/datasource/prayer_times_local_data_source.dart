import 'package:hive/hive.dart';
import 'package:nidaa/prayer_time/data/model/prayer_times_hive_model.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

abstract class PrayerTimesLocalDataSource {
  Future<void> cachePrayerTimes(List<PrayerTimes> prayerTimes);
  List<PrayerTimes> getCachedPrayerTimes();
  Future<void> clearPrayerTimes();
  Future<void> removePrayerTimesBefore(DateTime date);
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  static const String _boxName = 'prayer_time_box';
  Box<PrayerTimesHiveModel> get _box =>
      Hive.box<PrayerTimesHiveModel>(_boxName);

  @override
  Future<void> cachePrayerTimes(List<PrayerTimes> prayerTimes) async {
    for (final prayerTimesForDay in prayerTimes) {
      if (prayerTimesForDay.date.isNotEmpty) {
        await _box.put(
          prayerTimesForDay.date,
          PrayerTimesHiveModel.fromEntity(prayerTimesForDay),
        );
      }
    }
  }

  @override
  List<PrayerTimes> getCachedPrayerTimes() {
    return _box.values.map((item) => item.toEntity()).toList();
  }

  @override
  Future<void> clearPrayerTimes() async {
    await _box.clear();
  }

  @override
  Future<void> removePrayerTimesBefore(DateTime date) async {
    final keysToRemove = _box.keys.where((key) {
      final cachedDate = _parseDate(key.toString());
      return cachedDate != null && cachedDate.isBefore(date);
    }).toList();
    await _box.deleteAll(keysToRemove);
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }
}
