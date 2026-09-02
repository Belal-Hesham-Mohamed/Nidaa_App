import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/location/domain/entities/location.dart';
import 'package:nidaa/location/domain/repositories/location_repo_domain.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';

class PrayerTimesFlowResult {
  final Location? location;
  final PrayerTimes today;
  final PrayerTimes? nextDay;

  const PrayerTimesFlowResult({
    this.location,
    required this.today,
    this.nextDay,
  });
}

class LoadPrayerTimes {
  final PrayerTimesRepositoryDomain prayerTimesRepository;
  final LocationRepoDomain locationRepository;

  const LoadPrayerTimes({
    required this.prayerTimesRepository,
    required this.locationRepository,
  });

  Future<Either<Failure, PrayerTimesFlowResult>> call({
    bool forceCurrentLocation = false,
  }) async {
    final today = _dateOnly(DateTime.now());
    final hasInternet = await prayerTimesRepository.hasInternetConnection();
    if (!hasInternet) {
      return _fromCache(today, null, noInternet: true);
    }

    Location? location = locationRepository.getSavedLocation();
    if (forceCurrentLocation) {
      final gpsResult = await _getCurrentGpsLocation();
      final failure = gpsResult.fold<Failure?>((value) => value, (_) => null);
      if (failure != null) return Left(failure);
      final gpsLocation = gpsResult.fold<Location?>(
        (_) => null,
        (value) => value,
      )!;
      final shouldRefresh =
          location == null ||
          location.isManual ||
          location.city != gpsLocation.city ||
          location.country != gpsLocation.country;
      location = gpsLocation;
      await locationRepository.saveLocation(location);
      if (shouldRefresh) {
        await prayerTimesRepository.clearCachedPrayerTimes();
      }
    } else if (location == null) {
      final gpsResult = await _getCurrentGpsLocation();
      final failure = gpsResult.fold<Failure?>((value) => value, (_) => null);
      if (failure != null) return Left(failure);
      location = gpsResult.fold<Location?>((_) => null, (value) => value)!;
      await locationRepository.saveLocation(location);
    } else if (!location.isManual) {
      final current = await locationRepository.getCurrentLocation();
      final failure = current.fold<Failure?>((value) => value, (_) => null);
      if (failure != null) return Left(failure);
      final currentLocation = current.fold<Location?>(
        (_) => null,
        (value) => value,
      )!;
      if (currentLocation.city != location.city ||
          currentLocation.country != location.country) {
        location = Location(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          country: currentLocation.country,
          city: currentLocation.city,
          isManual: false,
        );
        await locationRepository.saveLocation(location);
        await prayerTimesRepository.clearCachedPrayerTimes();
      }
    }

    try {
      var cached = prayerTimesRepository.getCachedPrayerTimes();
      if (!_hasRequiredRange(cached, today)) {
        final months = _requiredMonths(today);
        for (final month in months) {
          final result = location.isManual
              ? await prayerTimesRepository.getPrayerTimesCalendarByCity(
                  city: location.city,
                  country: location.country,
                  month: month.month,
                  year: month.year,
                )
              : await prayerTimesRepository.getPrayerTimesCalendarByCoordinates(
                  latitude: location.latitude,
                  longitude: location.longitude,
                  month: month.month,
                  year: month.year,
                );
          final failure = result.fold<Failure?>((value) => value, (_) => null);
          if (failure != null) return Left(failure);
        }
        cached = prayerTimesRepository.getCachedPrayerTimes();
        await prayerTimesRepository.removeCachedPrayerTimesBefore(
          today.subtract(const Duration(days: 7)),
        );
      }
      return _fromCache(today, location, cached: cached);
    } catch (_) {
      return const Left(PrayerTimesFailure());
    }
  }

  Future<Either<Failure, Location>> _getCurrentGpsLocation() async {
    final result = await locationRepository.getCurrentLocation();
    return result.fold(
      (failure) => Left(failure),
      (value) => Right(
        Location(
          latitude: value.latitude,
          longitude: value.longitude,
          country: value.country,
          city: value.city,
          isManual: false,
        ),
      ),
    );
  }

  Either<Failure, PrayerTimesFlowResult> _fromCache(
    DateTime today,
    Location? location, {
    List<PrayerTimes>? cached,
    bool noInternet = false,
  }) {
    final values = cached ?? prayerTimesRepository.getCachedPrayerTimes();
    final todayPrayer = _find(values, today);
    if (todayPrayer == null) {
      return Left(
        noInternet
            ? const PrayerTimesNoInternetFailure()
            : const PrayerTimesFailure(),
      );
    }
    return Right(
      PrayerTimesFlowResult(
        location: location,
        today: todayPrayer,
        nextDay: _find(values, today.add(const Duration(days: 1))),
      ),
    );
  }

  bool _hasRequiredRange(List<PrayerTimes> values, DateTime today) {
    for (var offset = -7; offset <= 7; offset++) {
      if (_find(values, today.add(Duration(days: offset))) == null) {
        return false;
      }
    }
    return true;
  }

  List<DateTime> _requiredMonths(DateTime today) {
    final first = DateTime(today.year, today.month, today.day - 7);
    final last = DateTime(today.year, today.month, today.day + 7);
    final months = <DateTime>[];
    var cursor = DateTime(first.year, first.month);
    final end = DateTime(last.year, last.month);
    while (!cursor.isAfter(end)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return months;
  }

  PrayerTimes? _find(List<PrayerTimes> values, DateTime date) {
    final expected = _formatDate(date);
    for (final value in values) {
      if (value.date == expected) return value;
    }
    return null;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-${value.year}';
}
