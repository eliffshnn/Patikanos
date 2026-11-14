import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'weather_model.dart';

class DetailScreen extends StatelessWidget {
  final WeatherScore data;
  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hours = data.hourly.where((h) {
      final hour = int.parse(h.time.substring(0, 2));
      return hour >= 6 && hour < 21;
    }).toList();
    final title = data.activity == 'bike' ? 'Bisiklet' : 'Yürüyüş';

    return Scaffold(
      appBar: AppBar(title: Text('Saatlik detay · $title')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: hours.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
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
    final color = scoreColor(hour.score);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isNow ? AppColors.sea : AppColors.line, width: isNow ? 1.6 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hour.time, style: Theme.of(context).textTheme.titleMedium),
                if (isNow)
                  const Text('Şimdi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.sea)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: hour.score / 10,
                    minHeight: 8,
                    color: color,
                    backgroundColor: AppColors.sandDark,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _Metric(icon: Icons.thermostat_rounded, label: '${hour.feelsLike.toStringAsFixed(0)}°C'),
                    _Metric(icon: Icons.air_rounded, label: '${hour.wind.toStringAsFixed(0)} km/s'),
                    _Metric(icon: Icons.umbrella_rounded, label: '%${hour.rainProb}'),
                    _Metric(icon: Icons.wb_sunny_outlined, label: 'UV ${hour.uv.toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
            child: Text(
              '${hour.score}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
