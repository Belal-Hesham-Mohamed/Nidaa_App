import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';

class HijriDateModel extends HijriDate {
  const HijriDateModel({
    required super.day,
    required super.month,
    required super.year,
  });

  factory HijriDateModel.fromJson(Map<String, dynamic> json) {
    final month = json['month'] as Map<String, dynamic>;

    return HijriDateModel(
      day: json['day'].toString(),
      month: month['en'].toString(),
      year: json['year'].toString(),
    );
  }
}
