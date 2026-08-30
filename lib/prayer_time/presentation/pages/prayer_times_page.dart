import 'package:flutter/material.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/injection_container.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/domain/usecase/prayer_time_coordinates.dart';

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  Future<PrayerTimes> _loadPrayerTimes() async {
    final result = await sl<GetPrayerTimeCoordinates>()(
      latitude: 30.0444,
      longitude: 31.2357,
      date: '30-08-2026',
    );

    return result.fold(
      (failure) => throw failure,
      (prayerTimes) => prayerTimes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: FutureBuilder<PrayerTimes>(
        future: _loadPrayerTimes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is Failure
                ? error.massage
                : 'Failed to load prayer times';
            return Center(child: Text(message));
          }

          final prayerTimes = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('Prayer', [
                'Fajr: ${prayerTimes.prayer.fajr}',
                'Sunrise: ${prayerTimes.prayer.sunrise}',
                'Dhuhr: ${prayerTimes.prayer.dhuhr}',
                'Asr: ${prayerTimes.prayer.asr}',
                'Sunset: ${prayerTimes.prayer.sunset}',
                'Maghrib: ${prayerTimes.prayer.maghrib}',
                'Isha: ${prayerTimes.prayer.isha}',
              ]),
              _section('Night Times', [
                'Midnight: ${prayerTimes.nightTimes.midnight}',
                'First third: ${prayerTimes.nightTimes.firstThird}',
                'Last third: ${prayerTimes.nightTimes.lastThird}',
              ]),
              _section('Hijri Date', [
                'Day: ${prayerTimes.hijriDate.day}',
                'Month: ${prayerTimes.hijriDate.month}',
                'Year: ${prayerTimes.hijriDate.year}',
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<String> values) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...values.map(Text.new),
          ],
        ),
      ),
    );
  }
}
