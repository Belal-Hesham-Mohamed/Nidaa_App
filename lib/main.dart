import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nidaa/core/injection_container.dart';
import 'package:nidaa/location/data/model/location_model.dart';
import 'package:nidaa/prayer_time/data/model/prayer_submodels_hive.dart';
import 'package:nidaa/prayer_time/data/model/prayer_times_hive_model.dart';
import 'package:nidaa/prayer_time/presentation/pages/prayer_times_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();

  await Hive.initFlutter();

  Hive.registerAdapter(LocationModelAdapter());
  Hive.registerAdapter(PrayerHiveModelAdapter());
  Hive.registerAdapter(NightTimesHiveModelAdapter());
  Hive.registerAdapter(HijriDateHiveModelAdapter());
  Hive.registerAdapter(PrayerTimesHiveModelAdapter());

  await Hive.openBox<LocationModel>('locationBox');
  await Hive.openBox<PrayerTimesHiveModel>('prayer_time_box');
  runApp(const PrayerTimesApp());
}

class PrayerTimesApp extends StatelessWidget {
  const PrayerTimesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prayer Times',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const PrayerTimesPage(),
    );
  }
}
