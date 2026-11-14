import 'home_screen.dart' show weatherBackground;
import 'package:flutter/material.dart';

import 'weather_model.dart';

class DetailScreen extends StatelessWidget {
  final WeatherScore data;
  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hours = data.hourly;
    final title = data.activity == 'bike' ? 'Bisiklet' : 'Yürüyüş';

    return Scaffold(
            backgroundColor: weatherBackground,
      appBar: AppBar(
        backgroundColor: weatherBackground,
        title: Text('Saatlik detay · $title'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: hours.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) =>
            _HourRow(hour: hours[i], isNow: hours[i].time == data.nowTime),
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  final HourlyWeather hour;
  final bool isNow;
  const _HourRow({required this.hour, required this.isNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isNow ? Colors.blue.withValues(alpha: 0.08) : null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  hour.time,
                  style: TextStyle(fontWeight: isNow ? FontWeight.bold : FontWeight.normal),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hour.score / 10,
                    minHeight: 10,
                    color: scoreColor(hour.score),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 28,
                child: Text(
                  '${hour.score}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
                    Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                _Info(Icons.thermostat, '${hour.feelsLike.toStringAsFixed(0)}°C'),
                _Info(Icons.air, '${hour.wind.toStringAsFixed(0)} km/s'),
                _Info(Icons.umbrella, '%${hour.rainProb}'),
                _Info(Icons.wb_sunny, 'UV ${hour.uv.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}