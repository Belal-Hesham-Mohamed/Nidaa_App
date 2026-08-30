import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:nidaa/prayer_time/data/datasource/prayer_times_remote_data_source.dart';
import 'package:nidaa/prayer_time/data/repositories/prayer_times_repo.dart';
import 'package:nidaa/prayer_time/domain/repositories/prayer_time_repo_domain.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_city.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_coordinates.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<PrayerTimesRemoteDataSource>(
    () => PrayerTimesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PrayerTimesRepositoryDomain>(
    () => PrayerTimesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetPrayerTimeCoordinates>(
    () => GetPrayerTimeCoordinates(sl()),
  );
  sl.registerLazySingleton<GetPrayerTimesByCity>(
    () => GetPrayerTimesByCity(sl()),
  );
}
