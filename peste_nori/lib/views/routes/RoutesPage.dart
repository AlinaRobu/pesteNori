import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/HikeHistoryService.dart';

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

  Future<void> _editWeather(HikeRecord hike) async {
    final form = GlobalKey<FormState>();
    var weather = hike.weather ?? '';
    var temperature = hike.temperatureC?.toString() ?? '';
    double? parsedTemperature() =>
        double.tryParse(temperature.trim().replaceAll(',', '.'));

    final result = await showDialog<({String? weather, double? temperature})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weather notes'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: weather,
                decoration: const InputDecoration(labelText: 'Conditions'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Unspecified')),
                  for (final condition in _conditions)
                    DropdownMenuItem(value: condition, child: Text(condition)),
                ],
                onChanged: (value) => weather = value ?? '',
              ),
              TextFormField(
                initialValue: temperature,
                decoration: const InputDecoration(
                  labelText: 'Temperature (\u00b0C)',
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
                      ? 'Enter a temperature from -90 to 65'
                      : null;
                },
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
            onPressed: () {
              if (!form.currentState!.validate()) return;
              Navigator.pop(context, (
                weather: weather.isEmpty ? null : weather,
                temperature: parsedTemperature(),
              ));
            },
            child: const Text('Save'),
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
          const SnackBar(content: Text('Could not save weather notes.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_jm();
    return Scaffold(
      appBar: AppBar(title: const Text('Hike history')),
      body: StreamBuilder<List<HikeRecord>>(
        stream: _hikes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load hike history'));
          }
          final hikes = snapshot.data;
          if (hikes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (hikes.isEmpty) {
            return const Center(
              child: Text('Start a trail on the Map to see it here.'),
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
                  title: Text(hike.trailName),
                  subtitle: Text(
                    [
                      'Started ${date.format(hike.startedAt.toLocal())}',
                      if (end != null)
                        'Ended ${date.format(end.toLocal())}'
                      else
                        'End time not recorded',
                      if (duration != null)
                        'Duration ${duration.inHours} h ${duration.inMinutes.remainder(60)} min',
                      if (hike.weather != null || temperature != null)
                        [
                          if (hike.weather != null) hike.weather!,
                          if (temperature != null) '$temperature \u00b0C',
                        ].join(' \u00b7 '),
                    ].join('\n'),
                  ),
                  trailing: IconButton(
                    tooltip: 'Edit weather notes',
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
