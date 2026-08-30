import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa/core/injection_container.dart';
import 'package:nidaa/location/domain/usecase/get_current_loc_usecase.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/presentation/pages/cubit/prayer_time_cubit.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PrayerTimeCubit>(),
      child: const _PrayerTimesView(),
    );
  }
}

class _PrayerTimesView extends StatefulWidget {
  const _PrayerTimesView();

  @override
  State<_PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<_PrayerTimesView> {
  String _locationMode = 'Current GPS Location';
  String? _selectedCountry;
  String? _selectedCity;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  String get _currentDate {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day-$month-${now.year}';
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _locationMode = 'Current GPS Location';
      _selectedCountry = null;
      _selectedCity = null;
      _locationError = null;
    });

    final result = await sl<GetCurrentLocation>()();
    if (!mounted) return;

    result.fold(
      (failure) => setState(() => _locationError = failure.massage),
      (location) => context.read<PrayerTimeCubit>().getPrayerTimeByCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
        date: _currentDate,
      ),
    );
  }

  Future<void> _changeLocation() async {
    final countries = await UniCountryServices.instance.getCountriesAndCities();
    if (!mounted) return;

    final selectedCountry = await showDialog<Country>(
      context: context,
      builder: (_) => _SelectableListDialog<Country>(
        title: 'Select Country',
        items: countries,
        labelBuilder: (country) => country.nameEn,
      ),
    );
    if (!mounted || selectedCountry == null) return;

    final selectedCity = await showDialog<City>(
      context: context,
      builder: (_) => _SelectableListDialog<City>(
        title: 'Select City',
        items: selectedCountry.cities,
        labelBuilder: (city) => city.nameEn,
      ),
    );
    if (!mounted || selectedCity == null) return;

    setState(() {
      _locationMode = 'Manual Location';
      _selectedCountry = selectedCountry.nameEn;
      _selectedCity = selectedCity.nameEn;
      _locationError = null;
    });
    context.read<PrayerTimeCubit>().getPrayerTimeByCity(
      city: selectedCity.nameEn,
      country: selectedCountry.nameEn,
      date: _currentDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _locationCard(),
              const SizedBox(height: 16),
              if (_locationError != null) _errorCard(_locationError!),
              if (state is PrayerTimeLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is PrayerTimeError)
                _errorCard(state.message)
              else if (state is PrayerTimeSuccess)
                _prayerTimesCard(state.prayerTimes)
              else if (_locationError == null)
                const Center(child: Text('Waiting for location...')),
            ],
          );
        },
      ),
    );
  }

  Widget _locationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_locationMode),
            if (_selectedCity != null && _selectedCountry != null)
              Text('$_selectedCity, $_selectedCountry'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _loadCurrentLocation,
                  child: const Text('Use Current Location'),
                ),
                FilledButton(
                  onPressed: _changeLocation,
                  child: const Text('Change Location'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message),
            TextButton(
              onPressed: _loadCurrentLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prayerTimesCard(PrayerTimes prayerTimes) {
    return Column(
      children: [
        _section('Prayer', {
          'Fajr': prayerTimes.prayer.fajr,
          'Sunrise': prayerTimes.prayer.sunrise,
          'Dhuhr': prayerTimes.prayer.dhuhr,
          'Asr': prayerTimes.prayer.asr,
          'Sunset': prayerTimes.prayer.sunset,
          'Maghrib': prayerTimes.prayer.maghrib,
          'Isha': prayerTimes.prayer.isha,
        }),
        _section('Night', {
          'Midnight': prayerTimes.nightTimes.midnight,
          'First Third': prayerTimes.nightTimes.firstThird,
          'Last Third': prayerTimes.nightTimes.lastThird,
        }),
        _section('Hijri Date', {
          'Day': prayerTimes.hijriDate.day,
          'Month': prayerTimes.hijriDate.month,
          'Year': prayerTimes.hijriDate.year,
        }),
      ],
    );
  }

  Widget _section(String title, Map<String, String> values) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...values.entries.map(
            (entry) => ListTile(
              dense: true,
              title: Text(entry.key),
              trailing: Text(entry.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableListDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T item) labelBuilder;

  const _SelectableListDialog({
    required this.title,
    required this.items,
    required this.labelBuilder,
  });

  @override
  State<_SelectableListDialog<T>> createState() =>
      _SelectableListDialogState<T>();
}

class _SelectableListDialogState<T> extends State<_SelectableListDialog<T>> {
  T? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ListTile(
                    selected: identical(item, _selectedItem),
                    leading: Icon(
                      identical(item, _selectedItem)
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(widget.labelBuilder(item)),
                    onTap: () => setState(() => _selectedItem = item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedItem == null
              ? null
              : () => Navigator.pop(context, _selectedItem),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
