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
  Future<bool> hasInternetConnection() =>
      remoteDataSource.checkInternetConnection();

  @override
  List<PrayerTimes> getCachedPrayerTimes() =>
      localDataSource.getCachedPrayerTimes();

  @override
  Future<void> cachePrayerTimes(List<PrayerTimes> prayerTimes) =>
      localDataSource.cachePrayerTimes(prayerTimes);

  @override
  Future<void> clearCachedPrayerTimes() => localDataSource.clearPrayerTimes();

  @override
  Future<void> removeCachedPrayerTimesBefore(DateTime date) =>
      localDataSource.removePrayerTimesBefore(date);

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
      await localDataSource.cachePrayerTimes([result]);
      return Right(result);
    } on PrayerTimesException catch (exception) {
      return Left(_failureFor(exception));
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
      await localDataSource.cachePrayerTimes([result]);
      return Right(result);
    } on PrayerTimesException catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>>
  getPrayerTimesCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    try {
      final result = await remoteDataSource.getPrayerTimesCalendarByCoordinates(
        latitude: latitude,
        longitude: longitude,
        month: month,
        year: year,
      );
      await localDataSource.cachePrayerTimes(result);
      return Right(result);
    } on PrayerTimesException catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  @override
  Future<Either<Failure, List<PrayerTimes>>> getPrayerTimesCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  }) async {
    try {
      final result = await remoteDataSource.getPrayerTimesCalendarByCity(
        city: city,
        country: country,
        month: month,
        year: year,
      );
      await localDataSource.cachePrayerTimes(result);
      return Right(result);
    } on PrayerTimesException catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  Failure _failureFor(PrayerTimesException exception) {
    if (exception is PrayerTimesNetworkException) {
      return const PrayerTimesNetworkFailure();
    }
    if (exception is PrayerTimesServerException) {
      return const PrayerTimesServerFailure();
    }
    return const PrayerTimesFailure();
  }
}
