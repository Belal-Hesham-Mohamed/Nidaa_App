import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

abstract class PrayerTimesRepositoryDomain {
  Future<bool> hasInternetConnection();

  Future<Either<Failure, PrayerTimes>> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  });

  Future<Either<Failure, PrayerTimes>> getPrayerTimesByCity({
    required String city,
    required String country,
    required String date,
  });

  Future<Either<Failure, List<PrayerTimes>>>
  getPrayerTimesCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  });

  Future<Either<Failure, List<PrayerTimes>>> getPrayerTimesCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  });

  List<PrayerTimes> getCachedPrayerTimes();
  Future<void> cachePrayerTimes(List<PrayerTimes> prayerTimes);
  Future<void> clearCachedPrayerTimes();
  Future<void> removeCachedPrayerTimesBefore(DateTime date);
}
