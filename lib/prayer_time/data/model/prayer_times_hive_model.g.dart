// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_hive_model.dart';

class PrayerTimesHiveModelAdapter extends TypeAdapter<PrayerTimesHiveModel> {
  @override
  final int typeId = 1;

  @override
  PrayerTimesHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesHiveModel(
      date: (fields[3] as String?) ?? '',
      prayer: fields[0] as PrayerHiveModel,
      nightTimes: fields[1] as NightTimesHiveModel,
      hijriDate: fields[2] as HijriDateHiveModel,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.prayer)
      ..writeByte(1)
      ..write(obj.nightTimes)
      ..writeByte(2)
      ..write(obj.hijriDate)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
