import 'package:hive/hive.dart';
import 'package:nidaa/prayer_time/data/model/prayer_times_hive_model.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

abstract class PrayerTimesLocalDataSource {
  Future<void> cachePrayerTimes(PrayerTimes prayerTimes);
  PrayerTimes? getCachedPrayerTimes();
}

class PrayerTimesLocalDataSourceImpl implements PrayerTimesLocalDataSource {
  static const String _boxName = 'prayer_time_box';
  static const String _cacheKey = 'cached_prayer_times';

  Box<PrayerTimesHiveModel> get _box => Hive.box<PrayerTimesHiveModel>(_boxName);

  @override
  Future<void> cachePrayerTimes(PrayerTimes prayerTimes) async {
    await _box.put(_cacheKey, PrayerTimesHiveModel.fromEntity(prayerTimes));
  }

  @override
  PrayerTimes? getCachedPrayerTimes() {
    return _box.get(_cacheKey)?.toEntity();
  }
}
