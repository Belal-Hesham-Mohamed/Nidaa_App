part of 'prayer_time_cubit.dart';

sealed class PrayerTimeState extends Equatable {
  const PrayerTimeState();

  @override
  List<Object> get props => [];
}

final class PrayerTimeInitial extends PrayerTimeState {}

final class PrayerTimeLoading extends PrayerTimeState {}

final class PrayerTimeSuccess extends PrayerTimeState {
  final PrayerTimes prayerTimes;

  const PrayerTimeSuccess(this.prayerTimes);

  @override
  List<Object> get props => [prayerTimes];
}

final class PrayerTimeError extends PrayerTimeState {
  final String message;

  const PrayerTimeError(this.message);

  @override
  List<Object> get props => [message];
}
