import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';

class GetPrayerTimeCoordinates {
       final PrayerTimesRepositoryDomain repository;

  const GetPrayerTimeCoordinates(this.repository);

  Future<Either<Failure, PrayerTimes>> call({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    return await repository.getPrayerTimesByCoordinates(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
  }
}