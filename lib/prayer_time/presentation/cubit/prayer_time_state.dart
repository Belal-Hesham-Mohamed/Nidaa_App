part of 'prayer_time_cubit.dart';

sealed class PrayerTimeState extends Equatable {
  const PrayerTimeState();

  @override
  List<Object?> get props => [];
}

final class PrayerTimeInitial extends PrayerTimeState {
  const PrayerTimeInitial();
}

final class PrayerTimeLoading extends PrayerTimeState {}

final class NoInternetAvailable extends PrayerTimeState {
  final PrayerTimeState previousState;
  final Object _eventToken;

  NoInternetAvailable([this.previousState = const PrayerTimeInitial()])
    : _eventToken = Object();

  @override
  List<Object> get props => [previousState, _eventToken];
}

final class PrayerTimeSuccess extends PrayerTimeState {
  final PrayerTimes prayerTimes;
  final Location? location;
  final PrayerTimes? nextDay;

  const PrayerTimeSuccess(this.prayerTimes, {this.location, this.nextDay});

  @override
  List<Object?> get props => [prayerTimes, location, nextDay];
}

final class PrayerTimeError extends PrayerTimeState {
  final String message;

  const PrayerTimeError(this.message);

  @override
  List<Object> get props => [message];
}
