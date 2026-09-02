// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_submodels_hive.dart';

class PrayerHiveModelAdapter extends TypeAdapter<PrayerHiveModel> {
  @override
  final int typeId = 2;

  @override
  PrayerHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerHiveModel(
      fajr: fields[0] as String,
      sunrise: fields[1] as String,
      dhuhr: fields[2] as String,
      asr: fields[3] as String,
      sunset: fields[4] as String,
      maghrib: fields[5] as String,
      isha: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.fajr)
      ..writeByte(1)
      ..write(obj.sunrise)
      ..writeByte(2)
      ..write(obj.dhuhr)
      ..writeByte(3)
      ..write(obj.asr)
      ..writeByte(4)
      ..write(obj.sunset)
      ..writeByte(5)
      ..write(obj.maghrib)
      ..writeByte(6)
      ..write(obj.isha);
  }
}

class NightTimesHiveModelAdapter extends TypeAdapter<NightTimesHiveModel> {
  @override
  final int typeId = 3;

  @override
  NightTimesHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NightTimesHiveModel(
      midnight: fields[0] as String,
      firstThird: fields[1] as String,
      lastThird: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NightTimesHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.midnight)
      ..writeByte(1)
      ..write(obj.firstThird)
      ..writeByte(2)
      ..write(obj.lastThird);
  }
}

class HijriDateHiveModelAdapter extends TypeAdapter<HijriDateHiveModel> {
  @override
  final int typeId = 4;

  @override
  HijriDateHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HijriDateHiveModel(
      day: fields[0] as String,
      month: fields[1] as String,
      year: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HijriDateHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.year);
  }
}
