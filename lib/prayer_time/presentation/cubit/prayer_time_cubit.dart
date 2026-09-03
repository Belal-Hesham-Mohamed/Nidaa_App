import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa/location/domain/entities/location.dart';
import 'package:nidaa/location/domain/usecase/get_current_loc_usecase.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_city.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_coordinates.dart';
import 'package:nidaa/prayer_time/domain/usecase/load_prayer_times.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';

part 'prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  final GetPrayerTimeCoordinates getPrayerTimeCoordinates;
  final GetPrayerTimesByCity getPrayerTimesByCity;
  final LoadPrayerTimes loadPrayerTimes;
  final SaveLocation saveLocation;
  final PrayerTimesRepositoryDomain prayerTimesRepository;

  PrayerTimeCubit({
    required this.getPrayerTimeCoordinates,
    required this.getPrayerTimesByCity,
    required this.loadPrayerTimes,
    required this.saveLocation,
    required this.prayerTimesRepository,
  }) : super(PrayerTimeInitial());

  Future<void> start({bool forceCurrentLocation = false}) async {
    final result = await loadPrayerTimes(
      forceCurrentLocation: forceCurrentLocation,
      onLoading: () => emit(PrayerTimeLoading()),
    );
    result.fold(
      (failure) => emit(PrayerTimeError(failure.massage)),
      (value) => emit(
        PrayerTimeSuccess(
          value.today,
          location: value.location,
          nextDay: value.nextDay,
        ),
      ),
    );
  }

  Future<void> useCurrentLocation() async {
    await start(forceCurrentLocation: true);
  }

  Future<bool> ensureInternetAvailable() async {
    final hasInternet = await prayerTimesRepository.hasInternetConnection();
    if (!hasInternet) emit(NoInternetAvailable(state));
    return hasInternet;
  }

  Future<void> useManualLocation({
    required String city,
    required String country,
  }) async {
    if (!await ensureInternetAvailable()) return;

    await prayerTimesRepository.clearCachedPrayerTimes();
    await saveLocation(
      Location(
        latitude: 0,
        longitude: 0,
        city: city,
        country: country,
        isManual: true,
      ),
    );
    await start();
  }

  //if date and location
  Future<void> getPrayerTimeByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    if (!await ensureInternetAvailable()) return;

    emit(PrayerTimeLoading());

    final result = await getPrayerTimeCoordinates(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    result.fold(
      (failure) => emit(PrayerTimeError(failure.massage)),
      (prayerTimes) => emit(PrayerTimeSuccess(prayerTimes)),
    );
  }

  Future<void> getPrayerTimeByCity({
    required String city,
    required String country,
    required String date,
  }) async {
    if (!await ensureInternetAvailable()) return;

    emit(PrayerTimeLoading());

    final result = await getPrayerTimesByCity(
      city: city,
      country: country,
      date: date,
    );

    result.fold(
      (failure) => emit(PrayerTimeError(failure.massage)),
      (prayerTimes) => emit(PrayerTimeSuccess(prayerTimes)),
    );
  }
}
