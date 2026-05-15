import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/solar_forecast.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({
    super.key,
    required this.forecast,
    required this.loading,
    required this.errorMessage,
    required this.onOpenDashboard,
    this.scrollController,
  });

  final SolarForecast? forecast;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onOpenDashboard;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        _HeaderCard(strings: strings),
        const SizedBox(height: 16),
        if (loading)
          const _LoadingCard()
        else ...[
          if (errorMessage != null)
            _MessageCard(
              icon: Icons.cloud_off_outlined,
              title: strings.errorPrefix,
              body: errorMessage!,
            ),
          if (errorMessage != null) const SizedBox(height: 16),
          if (forecast == null)
            _EmptyForecastCard(
              strings: strings,
              onOpenDashboard: onOpenDashboard,
            )
          else ...[
            _TopWindowsCard(strings: strings, forecast: forecast!),
            const SizedBox(height: 16),
            _TimelineCard(strings: strings, forecast: forecast!),
            const SizedBox(height: 16),
            _ScoreInfoCard(strings: strings),
          ],
        ],
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondaryContainer,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.timelineTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.daylightOnlyBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withOpacity(
                      0.92,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.wb_sunny_outlined,
            size: 46,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

class _TopWindowsCard extends StatelessWidget {
  const _TopWindowsCard({required this.strings, required this.forecast});

  final AppStrings strings;
  final SolarForecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windows = forecast.windows.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.topWindowsTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (windows.isEmpty)
              Text(strings.noDaylightBody)
            else
              ...windows.map(
                (window) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatTime(window.start)} - ${_formatTime(window.end)}',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${strings.radiationLabel}: ${window.averageRadiation.toStringAsFixed(0)} W/m²',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '${strings.productionLabel}: ~${(window.averageRadiation / 1000 * 3000 * 0.8).toStringAsFixed(0)} W',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          window.averageScore.toStringAsFixed(0),
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.strings, required this.forecast});

  final AppStrings strings;
  final SolarForecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.timelineTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            SizedBox(
              height: 138,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.slots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final slot = forecast.slots[index];
                  return _HourTile(slot: slot, strings: strings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({required this.slot, required this.strings});

  final SolarForecastSlot slot;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = slot.isDaylight
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceVariant;
    final foreground = slot.isDaylight
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(slot.time),
            style: theme.textTheme.titleMedium?.copyWith(color: foreground),
          ),
          const SizedBox(height: 8),
          Icon(
            slot.isDaylight ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: foreground,
          ),
          const SizedBox(height: 8),
          Text(
            slot.isDaylight ? strings.daylightLabel : strings.nightLabel,
            style: theme.textTheme.labelLarge?.copyWith(color: foreground),
          ),
          const Spacer(),
          Text(
            '${slot.radiation} W/m2',
            style: theme.textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _EmptyForecastCard extends StatelessWidget {
  const _EmptyForecastCard({
    required this.strings,
    required this.onOpenDashboard,
  });

  final AppStrings strings;
  final VoidCallback onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.noForecastTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(strings.noForecastBody),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onOpenDashboard,
                icon: const Icon(Icons.arrow_back),
                label: Text(strings.openDashboardButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(strings.loading),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreInfoCard extends StatelessWidget {
  const _ScoreInfoCard({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.tertiaryContainer.withOpacity(0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.tertiary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.tips_and_updates_outlined, color: theme.colorScheme.tertiary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.scoreExplanationTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.scoreExplanationBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
