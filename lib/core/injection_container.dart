import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:nidaa/location/data/datasource/location_local_data_source.dart';
import 'package:nidaa/location/data/repositories/location_repository_impl.dart';
import 'package:nidaa/location/domain/repositories/location_repo_domain.dart';
import 'package:nidaa/location/domain/usecase/get_current_loc_usecase.dart';
import 'package:nidaa/prayer_time/domain/usecase/load_prayer_times.dart';
import 'package:nidaa/prayer_time/data/datasource/prayer_times_local_data_source.dart';
import 'package:nidaa/prayer_time/data/datasource/prayer_times_remote_data_source.dart';
import 'package:nidaa/prayer_time/data/repositories/prayer_times_repo.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_city.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_coordinates.dart';
import 'package:nidaa/prayer_time/presentation/cubit/prayer_time_cubit.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<LocationRepoDomain>(
    () => LocationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetCurrentLocation>(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton<GetSavedLocation>(() => GetSavedLocation(sl()));
  sl.registerLazySingleton<SaveLocation>(() => SaveLocation(sl()));
  sl.registerLazySingleton<PrayerTimesRemoteDataSource>(
    () => PrayerTimesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PrayerTimesLocalDataSource>(
    () => PrayerTimesLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PrayerTimesRepositoryDomain>(
    () => PrayerTimesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<GetPrayerTimeCoordinates>(
    () => GetPrayerTimeCoordinates(sl()),
  );
  sl.registerLazySingleton<GetPrayerTimesByCity>(
    () => GetPrayerTimesByCity(sl()),
  );
  sl.registerFactory<PrayerTimeCubit>(
    () => PrayerTimeCubit(
      getPrayerTimeCoordinates: sl(),
      getPrayerTimesByCity: sl(),
      loadPrayerTimes: sl(),
      saveLocation: sl(),
      prayerTimesRepository: sl(),
    ),
  );
  sl.registerLazySingleton<LoadPrayerTimes>(
    () =>
        LoadPrayerTimes(prayerTimesRepository: sl(), locationRepository: sl()),
  );
}
