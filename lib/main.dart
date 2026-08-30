import 'package:flutter/material.dart';
import 'package:nidaa/core/injection_container.dart';
import 'package:nidaa/prayer_time/presentation/pages/prayer_times_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
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
