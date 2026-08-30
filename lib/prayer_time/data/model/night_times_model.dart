import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

class NightTimesModel extends NightTimes {
  const NightTimesModel({
    required super.midnight,
    required super.firstThird,
    required super.lastThird,
  });

  factory NightTimesModel.fromJson(Map<String, dynamic> json) {
    return NightTimesModel(
      midnight: json['Midnight'].toString(),
      firstThird: json['Firstthird'].toString(),
      lastThird: json['Lastthird'].toString(),
    );
  }
}
