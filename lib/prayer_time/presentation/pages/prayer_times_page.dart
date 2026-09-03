import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nidaa/core/injection_container.dart';
import 'package:nidaa/prayer_time/domain/entities/prayer_time.dart';
import 'package:nidaa/prayer_time/presentation/cubit/prayer_time_cubit.dart';
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
  static const _ink = Color(0xFF163A35);
  static const _muted = Color(0xFF6E7E79);
  static const _mint = Color(0xFFDDEDE4);

  String _locationMode = 'Current GPS Location';
  String? _selectedCountry;
  String? _selectedCity;
  String? _locationError;
  DateTime _now = DateTime.now();
  Timer? _clock;
  final _nextPrayerKey = GlobalKey();
  bool _initialPositionSet = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _startPrayerTimes();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _startPrayerTimes() async {
    await context.read<PrayerTimeCubit>().start();
  }

  Future<void> _loadCurrentLocation() async {
    await context.read<PrayerTimeCubit>().start(forceCurrentLocation: true);
  }

  Future<void> _changeLocation() async {
    final cubit = context.read<PrayerTimeCubit>();
    if (!await cubit.ensureInternetAvailable()) return;

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

    await cubit.useManualLocation(
      city: selectedCity.nameEn,
      country: selectedCountry.nameEn,
    );
    if (!mounted) return;
    setState(() {
      _locationMode = 'Manual Location';
      _selectedCountry = selectedCountry.nameEn;
      _selectedCity = selectedCity.nameEn;
      _locationError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F2A),
      body: BlocListener<PrayerTimeCubit, PrayerTimeState>(
        listenWhen: (_, state) => state is NoInternetAvailable,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No internet available')),
          );
        },
        child: SafeArea(
          child: BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
            builder: (context, state) {
              var visibleState = state;
              while (visibleState is NoInternetAvailable) {
                visibleState = visibleState.previousState;
              }
              final success = visibleState is PrayerTimeSuccess
                  ? visibleState
                  : null;
              final isManualLocation =
                  success?.location?.isManual ??
                  (_selectedCity != null && _selectedCountry != null);
              if (success != null && !_initialPositionSet) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final target = _nextPrayerKey.currentContext;
                  if (target != null && mounted) {
                    _initialPositionSet = true;
                    Scrollable.ensureVisible(
                      target,
                      alignment: 0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                children: [
                  _topBar(isManualLocation: isManualLocation),
                  const SizedBox(height: 12),
                  _locationCard(success),
                  const SizedBox(height: 24),
                  if (_locationError != null) _errorCard(_locationError!),
                  if (success != null) ...[
                    _dateCard(),
                    const SizedBox(height: 12),
                    KeyedSubtree(
                      key: _nextPrayerKey,
                      child: _nextPrayerCard(
                        _nextPrayer(success.prayerTimes, success.nextDay),
                        success.prayerTimes,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (visibleState is PrayerTimeLoading)
                    _loadingCard()
                  else if (visibleState is PrayerTimeError)
                    _errorCard(visibleState.message)
                  else if (success != null)
                    _prayerTimesCard(success)
                  else if (_locationError == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(child: Text('Waiting for location...')),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar({required bool isManualLocation}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.mosque_outlined,
            color: Colors.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prayer Times',
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your day, guided by prayer',
                style: TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ),
        ),
        if (isManualLocation)
          IconButton(
            onPressed: _loadCurrentLocation,
            icon: const Icon(Icons.refresh_rounded),
            color: _ink,
            tooltip: 'Refresh location',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          ),
      ],
    );
  }

  Widget _locationCard(PrayerTimeSuccess? success) {
    final city = success?.location?.city ?? _selectedCity;
    final country = success?.location?.country ?? _selectedCountry;
    final isManual =
        success?.location?.isManual ??
        (_selectedCity != null && _selectedCountry != null);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EAE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: _ink, size: 17),
              const SizedBox(width: 5),
              Text(
                isManual ? 'Manual location' : 'Current location',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            city != null && country != null ? '$city, $country' : _locationMode,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (isManual)
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<PrayerTimeCubit>().useCurrentLocation(),
                  icon: const Icon(Icons.my_location_rounded, size: 14),
                  label: const Text('Use Current Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: Color(0xFFBBD0C4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              FilledButton.icon(
                onPressed: _changeLocation,
                icon: const Icon(Icons.edit_location_alt_outlined, size: 14),
                label: const Text('Change'),
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3D2CC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFB54C3F)),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: _loadCurrentLocation,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return const Padding(
      padding: EdgeInsets.only(top: 42),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: _ink),
            SizedBox(height: 14),
            Text('Preparing today\'s prayer times'),
          ],
        ),
      ),
    );
  }

  Widget _prayerTimesCard(PrayerTimeSuccess success) {
    final prayerTimes = success.prayerTimes;
    final nextPrayer = _nextPrayer(prayerTimes, success.nextDay);
    return Column(
      children: [
        _prayerSchedule(prayerTimes, nextPrayer.name),
        const SizedBox(height: 14),
        _secondaryCard(
          title: 'Night times',
          icon: Icons.nightlight_outlined,
          values: {
            'Midnight': prayerTimes.nightTimes.midnight,
            'First third': prayerTimes.nightTimes.firstThird,
            'Last third': prayerTimes.nightTimes.lastThird,
          },
        ),
      ],
    );
  }

  Widget _dateCard() {
    final date = _now;

    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2EAE4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14163A35),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: _ink,
                size: 18,
              ),
            ),

            const SizedBox(width: 11),

            Text(
              _dayName(date),
              style: const TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            Text(
              _displayDate(date),
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextPrayerCard(_NextPrayer nextPrayer, PrayerTimes prayerTimes) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24163A35),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT PRAYER',
                  style: TextStyle(
                    color: Color(0xFFA8C9B8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  nextPrayer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Text(
                  nextPrayer.time,
                  style: const TextStyle(
                    color: Color(0xFFA8C9B8),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 8),

                // Divider with center notch
                SizedBox(
                  height: 8,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 3,
                        child: Divider(
                          color: Color(0x4DA8C9B8),
                          thickness: 1,
                          height: 1,
                        ),
                      ),

                      Positioned(
                        top: 0,
                        child: Transform.rotate(
                          angle: 0.785398,
                          child: Container(width: 7, height: 7, color: _ink),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Text(
                      prayerTimes.hijriDate.day,
                      style: const TextStyle(
                        color: Color(0xFFE1F2E8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(width: 7),

                    const Text(
                      '•',
                      style: TextStyle(color: Color(0xFFA8C9B8), fontSize: 10),
                    ),

                    const SizedBox(width: 7),

                    Text(
                      prayerTimes.hijriDate.month,
                      style: const TextStyle(
                        color: Color(0xFFE1F2E8),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(width: 7),

                    const Text(
                      '•',
                      style: TextStyle(color: Color(0xFFA8C9B8), fontSize: 10),
                    ),

                    const SizedBox(width: 7),

                    Text(
                      prayerTimes.hijriDate.year,
                      style: const TextStyle(
                        color: Color(0xFFE1F2E8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nextPrayer.remaining,
                style: const TextStyle(
                  color: Color(0xFFE1F2E8),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const Text(
                'remaining',
                style: TextStyle(color: Color(0xFFA8C9B8), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _prayerSchedule(PrayerTimes prayerTimes, String nextPrayer) {
    final items = [
      _PrayerItem('Fajr', prayerTimes.prayer.fajr, Icons.wb_twilight_outlined),
      _PrayerItem(
        'Sunrise',
        prayerTimes.prayer.sunrise,
        Icons.wb_sunny_outlined,
      ),
      _PrayerItem('Dhuhr', prayerTimes.prayer.dhuhr, Icons.sunny),
      _PrayerItem('Asr', prayerTimes.prayer.asr, Icons.brightness_5_outlined),
      _PrayerItem(
        'Maghrib',
        prayerTimes.prayer.maghrib,
        Icons.nights_stay_outlined,
      ),
      _PrayerItem('Isha', prayerTimes.prayer.isha, Icons.dark_mode_outlined),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAE4)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _prayerTile(items[index], items[index].name == nextPrayer),
            if (index != items.length - 1)
              const Divider(height: 1, indent: 68, endIndent: 18),
          ],
        ],
      ),
    );
  }

  Widget _prayerTile(_PrayerItem item, bool isNext) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isNext ? _mint : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNext ? _ink : const Color(0xFFF0F5F1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: isNext ? Colors.white : _muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          if (isNext)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                'NEXT',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          Text(
            _cleanPrayerTime(item.time),
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

Widget _secondaryCard({
  required String title,
  required IconData icon,
  required Map<String, String> values,
}) {
  final Map<String, IconData> timeIcons = {
    'Midnight': Icons.nights_stay_outlined,
    'First third': Icons.brightness_2_outlined,
    'Last third': Icons.nightlight_outlined,
  };

  return Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE2EAE4),
      ),
    ),
    child: Column(
      children: [
        // Header
        Row(
          children: [
            Icon(
              icon,
              color: _muted,
              size: 18,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        // Night time rows
        ...values.entries.map(
          (entry) {
            final cleanValue = entry.value
                .replaceAll(' (EEST)', '')
                .replaceAll('(EEST)', '');

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _mint.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F5F1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        timeIcons[entry.key] ??
                            Icons.nightlight_outlined,
                        size: 18,
                        color: _muted,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Text(
                      cleanValue,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
  _NextPrayer _nextPrayer(PrayerTimes today, PrayerTimes? nextDay) {
    final prayers = <String, String>{
      'Fajr': today.prayer.fajr,
      'Sunrise': today.prayer.sunrise,
      'Dhuhr': today.prayer.dhuhr,
      'Asr': today.prayer.asr,
      'Maghrib': today.prayer.maghrib,
      'Isha': today.prayer.isha,
    };
    final now = _now;
    for (final entry in prayers.entries) {
      final time = _todayAt(entry.value, now);
      if (time != null && time.isAfter(now)) {
        return _NextPrayer(
          entry.key,
          _cleanPrayerTime(entry.value),
          _remaining(now, time),
        );
      }
    }
    if (nextDay != null) {
      final nextFajr = _todayAt(
        nextDay.prayer.fajr,
        now.add(const Duration(days: 1)),
      );
      if (nextFajr != null) {
        return _NextPrayer(
          'Fajr',
          _cleanPrayerTime(nextDay.prayer.fajr),
          _remaining(now, nextFajr),
        );
      }
    }
    return const _NextPrayer('-', '--:--', '--:--');
  }

  DateTime? _todayAt(String value, DateTime date) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
  }

  String _remaining(DateTime now, DateTime target) {
    final difference = target.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _dayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _displayDate(DateTime date) =>
      '${_monthName(date.month)} ${date.day}, ${date.year}';

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _cleanPrayerTime(String value) {
    return value
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s+(EST|EDT|UTC)\b'), '')
        .trim();
  }
}

class _NextPrayer {
  final String name;
  final String time;
  final String remaining;

  const _NextPrayer(this.name, this.time, this.remaining);
}

class _PrayerItem {
  final String name;
  final String time;
  final IconData icon;

  const _PrayerItem(this.name, this.time, this.icon);
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
