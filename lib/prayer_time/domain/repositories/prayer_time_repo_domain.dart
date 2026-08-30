import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
abstract class PrayerTimesRepositoryDomain {
 Future<Either<Failure, PrayerTimes>> getPrayerTimesByCoordinates({
  required double latitude,
  required double longitude,
  required String date,
});

Future<Either<Failure, PrayerTimes>> getPrayerTimesByCity({
  required String city,
  required String country,
  required String date,
});}