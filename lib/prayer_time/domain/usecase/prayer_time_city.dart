import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';

class GetPrayerTimesByCity {
  final PrayerTimesRepositoryDomain repository;

  const GetPrayerTimesByCity(this.repository);

  Future<Either<Failure, PrayerTimes>> call({
    required String city,
    required String country,
    required String date,
  }) async {
    return await repository.getPrayerTimesByCity(
      city: city,
      country: country,
      date:date
    );
  }
}