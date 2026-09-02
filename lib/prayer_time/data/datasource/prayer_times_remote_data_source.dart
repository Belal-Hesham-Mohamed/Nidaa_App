import 'package:dio/dio.dart';
import 'package:nidaa/core/constant/api_constant.dart';
import 'package:nidaa/prayer_time/data/exception/prayer_times_exception.dart';
import 'package:nidaa/prayer_time/data/model/prayer_times_model.dart';

abstract class PrayerTimesRemoteDataSource {
  Future<bool> checkInternetConnection();

  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  });

  Future<List<PrayerTimesModel>> getPrayerTimesCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  });

  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
    required String date,
  });

  Future<List<PrayerTimesModel>> getPrayerTimesCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  });
}

class PrayerTimesRemoteDataSourceImpl implements PrayerTimesRemoteDataSource {
  final Dio dio;

  PrayerTimesRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? Dio();

  @override
  Future<bool> checkInternetConnection() async {
    try {
      await dio.get(
        PrayerTimesApiConstants.baseUrl,
        options: Options(validateStatus: (_) => true),
      );
      return true;
    } on DioException {
      return false;
    }
  }

  @override
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    final url = PrayerTimesApiConstants.timingsByCoordinates(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );

    return _getPrayerTimes(url);
  }

  @override
  Future<List<PrayerTimesModel>> getPrayerTimesCalendarByCoordinates({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    final url = PrayerTimesApiConstants.calendarByCoordinates(
      latitude: latitude,
      longitude: longitude,
      month: month,
      year: year,
    );

    return _getPrayerTimesCalendar(url);
  }

  @override
  Future<PrayerTimesModel> getPrayerTimesByCity({
    required String city,
    required String country,
    required String date,
  }) async {
    final url = PrayerTimesApiConstants.timingsByCity(
      city: city,
      country: country,
      date: date,
    );

    return _getPrayerTimes(url);
  }

  @override
  Future<List<PrayerTimesModel>> getPrayerTimesCalendarByCity({
    required String city,
    required String country,
    required int month,
    required int year,
  }) async {
    final url = PrayerTimesApiConstants.calendarByCity(
      city: city,
      country: country,
      month: month,
      year: year,
    );

    return _getPrayerTimesCalendar(url);
  }

  Future<PrayerTimesModel> _getPrayerTimes(String url) async {
    try {
      final response = await dio.get(url);

      if (response.statusCode != 200) {
        throw const PrayerTimesServerException('Failed to load prayer times');
      }

      return PrayerTimesModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw PrayerTimesNetworkException(
        exception.message ?? 'Failed to connect to prayer times service',
      );
    } on PrayerTimesServerException {
      rethrow;
    } on PrayerTimesException {
      rethrow;
    } catch (exception) {
      throw PrayerTimesException(exception.toString());
    }
  }

  Future<List<PrayerTimesModel>> _getPrayerTimesCalendar(String url) async {
    try {
      final response = await dio.get(url);

      if (response.statusCode != 200) {
        throw const PrayerTimesServerException('Failed to load prayer times');
      }

      return PrayerTimesModel.fromCalendarJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (exception) {
      throw PrayerTimesNetworkException(
        exception.message ?? 'Failed to connect to prayer times service',
      );
    } on PrayerTimesServerException {
      rethrow;
    } on PrayerTimesException {
      rethrow;
    } catch (exception) {
      throw PrayerTimesException(exception.toString());
    }
  }
}
