import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_city.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_coordinates.dart';

part 'prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  final GetPrayerTimeCoordinates getPrayerTimeCoordinates;
  final GetPrayerTimesByCity getPrayerTimesByCity;

  PrayerTimeCubit({
    required this.getPrayerTimeCoordinates,
    required this.getPrayerTimesByCity,
  }) : super(PrayerTimeInitial());
//if date and location 
  Future<void> getPrayerTimeByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
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
