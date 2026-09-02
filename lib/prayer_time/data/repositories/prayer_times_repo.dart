import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/prayer_time/data/datasource/prayer_times_local_data_source.dart';
import 'package:nidaa/prayer_time/data/datasource/prayer_times_remote_data_source.dart';
import 'package:nidaa/prayer_time/data/exception/prayer_times_exception.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';

class PrayerTimesRepositoryImpl implements PrayerTimesRepositoryDomain {
  final PrayerTimesRemoteDataSource remoteDataSource;
  final PrayerTimesLocalDataSource localDataSource;

  PrayerTimesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PrayerTimes>> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    try {
      final result = await remoteDataSource.getPrayerTimesByCoordinates(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );

      await localDataSource.cachePrayerTimes(result);
      return Right(result);
    } on PrayerTimesNetworkException {
      final cached = localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return Right(cached);
      }
      return Left(PrayerTimesNetworkFailure());
    } on PrayerTimesServerException {
      final cached = localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return Right(cached);
      }
      return Left(PrayerTimesServerFailure());
    } on PrayerTimesException {
      final cached = localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return Right(cached);
      }
      return Left(PrayerTimesFailure());
    }
  }

  @override
  Future<Either<Failure, PrayerTimes>> getPrayerTimesByCity({
    required String city,
    required String country,
    required String date,
  }) async {
    try {
      final result = await remoteDataSource.getPrayerTimesByCity(
        city: city,
        country: country,
        date: date,
      );

      await localDataSource.cachePrayerTimes(result);
      return Right(result);
    } on PrayerTimesNetworkException {
      final cached = localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return Right(cached);
      }
      return Left(PrayerTimesNetworkFailure());
    } on PrayerTimesServerException {
      final cached = localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return Right(cached);
      }
      return Left(PrayerTimesServerFailure());
    } on PrayerTimesException {
      final cached = localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return Right(cached);
      }
      return Left(PrayerTimesFailure());
    }
  }
}
