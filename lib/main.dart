import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nidaa/core/injection_container.dart';
import 'package:nidaa/location/data/model/location_model.dart';
import 'package:nidaa/prayer_time/presentation/pages/prayer_times_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
    WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(LocationModelAdapter());

  await Hive.openBox<LocationModel>('locationBox');
  runApp(const PrayerTimesApp());
}

class PrayerTimesApp extends StatelessWidget {
  const PrayerTimesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const PrayerTimesPage(),
    );
  }
}
