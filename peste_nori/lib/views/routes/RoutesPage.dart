import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/HikeHistoryService.dart';
import 'package:peste_nori/globals.dart';
import '../map/models/HikingRoute.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final _history = HikeHistoryService();
  late final _hikes = _history.watchHistory();

  static const _conditions = [
    'Sunny',
    'Cloudy',
    'Rain',
    'Snow',
    'Fog',
    'Mixed',
  ];

  String _weatherLabel(String condition) => switch (condition) {
    'Sunny' => translations.weatherSunny,
    'Cloudy' => translations.weatherCloudy,
    'Rain' => translations.weatherRain,
    'Snow' => translations.weatherSnow,
    'Fog' => translations.weatherFog,
    'Mixed' => translations.weatherMixed,
    _ => translations.weatherUnspecified,
  };

  Future<void> _editWeather(HikeRecord hike) async {
    final form = GlobalKey<FormState>();
    var weather = hike.weather ?? '';
    var temperature = hike.temperatureC?.toString() ?? '';
    double? parsedTemperature() =>
        double.tryParse(temperature.trim().replaceAll(',', '.'));

    final result = await showDialog<({String? weather, double? temperature})>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translations.weatherNotes),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: weather,
                decoration: InputDecoration(labelText: translations.weatherConditions),
                items: [
                  DropdownMenuItem(value: '', child: Text(translations.weatherUnspecified)),
                  for (final condition in _conditions)
                    DropdownMenuItem(value: condition, child: Text(_weatherLabel(condition))),
                ],
                onChanged: (value) => weather = value ?? '',
              ),
              TextFormField(
                initialValue: temperature,
                decoration: InputDecoration(
                  labelText: translations.temperatureCelsius,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                onChanged: (value) => temperature = value,
                validator: (_) {
                  if (temperature.trim().isEmpty) return null;
                  final value = parsedTemperature();
                  return value == null ||
                          !value.isFinite ||
                          value < -90 ||
                          value > 65
                      ? translations.temperatureRange
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translations.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              Navigator.pop(context, (
                weather: weather.isEmpty ? null : weather,
                temperature: parsedTemperature(),
              ));
            },
            child: Text(translations.save),
          ),
        ],
      ),
    );
    if (result == null) return;
    try {
      await _history.saveWeather(hike.id, result.weather, result.temperature);
    } catch (error) {
      debugPrint('Could not save hike weather: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.weatherSaveError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_jm();
    return Scaffold(
      appBar: AppBar(title: Text(translations.hikeHistory)),
      body: StreamBuilder<List<HikeRecord>>(
        stream: _hikes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(translations.hikeHistoryLoadError));
          }
          final hikes = snapshot.data;
          if (hikes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (hikes.isEmpty) {
            return Center(
              child: Text(translations.hikeHistoryEmpty),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hikes.length,
            itemBuilder: (context, index) {
              final hike = hikes[index];
              final end = hike.endedAt;
              final duration = end?.difference(hike.startedAt);
              final temperature = hike.temperatureC;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.route),
                  title: Text(
                    hike.trailName == HikingRoute.unnamedTrailName
                        ? translations.unnamedTrail
                        : hike.trailName,
                  ),
                  subtitle: Text(
                    [
                      translations.hikeStartedAt(date.format(hike.startedAt.toLocal())),
                      if (end != null)
                        translations.hikeEndedAt(date.format(end.toLocal()))
                      else
                        translations.hikeEndNotRecorded,
                      if (duration != null)
                        translations.hikeDuration(duration.inHours.toString(), duration.inMinutes.remainder(60).toString()),
                      if (hike.weather != null || temperature != null)
                        [
                          if (hike.weather != null) _weatherLabel(hike.weather!),
                          if (temperature != null) translations.temperatureValue(NumberFormat.decimalPattern(translations.localeName).format(temperature)),
                        ].join(' \u00b7 '),
                    ].join('\n'),
                  ),
                  trailing: IconButton(
                    tooltip: translations.editWeatherNotes,
                    onPressed: () => _editWeather(hike),
                    icon: const Icon(Icons.cloud_outlined),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
